class Order < ApplicationRecord
  has_paper_trail
  belongs_to :user, optional: true
  belongs_to :account


  scope :approved,  ->{ where(aasm_state: 'approved')  }
  scope :pending,   ->{ where(aasm_state: 'pending')  }
  scope :ordered,  ->{ where(aasm_state: 'ordered')  }
  scope :submitted,  ->{ where(aasm_state: 'submitted')  }
  scope :received,   ->{ where(aasm_state: 'received')  }
  scope :rejected,   ->{ where(aasm_state: 'rejected')  }

  # https://simonecarletti.com/blog/2009/12/inside-ruby-on-rails-delegate/
  delegate :name, :to => :user, :prefix => :user, :allow_nil => true

  validates :name, presence: true
  validates :description, presence: true
  validates :part_number, presence: true
  validates :price, presence: true, numericality: true,
            :format => { :with => /\A\d+\.*\d{0,2}\z/ }
  validates :quantity, numericality: { :greater_than_or_equal_to => 1 }
  validates :supplier, presence: true
  validates :link, presence: true
  validates :aasm_state, presence: true

  @@notifier = Slack::Notifier.new ENV["WEBHOOK_URL"] do
    defaults channel: "#logistics",
             username: "fApper - Orders"
  end

  def after_import_save(record)
    self.update_attribute(:user_id, PaperTrail.whodunnit)
    # @@notifier.post text: "Order #" + self.id.to_s + " awaiting approval. \nOrder created by " + User.find(PaperTrail.whodunnit).name.to_s + " - " + self.name.to_s + ": $" + self.total_price.to_s, icon_emoji: ":ghost:"
    approval_note = {
      title: "Order ##{self.id.to_s} created.",
      fallback: "Order ##{self.id.to_s} created.",
      text: "#{self.name.to_s}: #{self.description.to_s}",
      author_name: "#{User.find(PaperTrail.whodunnit).name.to_s}",
      color: "good",
      # callback_id: "order/#{self.id.to_s}/state?attr=aasm_state&event=",
      attachment_type: "default",
      fields: [
          {
              "title": "Price",
              "value": "#{number_to_currency(self.total_price, :unit => "$")}"
          },
          {
              "title": "Link",
              "value": "#{self.link}"
          },
          {
              "title": "Approve",
              "color": "good",
              "value": "https://fapp.ubcchemecar.com/orders/#{self.id.to_s}/approve",
              short: true
          },
          {
              "title": "Reject",
              "color": "danger",
              "value": "https://fapp.ubcchemecar.com/orders/#{self.id.to_s}/reject",
              short: true
          }
        ]
    }
    @@notifier.post text: "New order needs approval.", at: :akrithar, attachments: [approval_note]
  end

  attr_reader :total_price
  def total_price
    price*quantity
  end

  include AASM
  aasm do
    state :pending, :initial => true
    state :approved
    state :submitted
    state :ordered
    state :received
    state :rejected

    event :approve do
      transitions :from => [:pending, :rejected], :to => :approved
      after do
        @@notifier.ping "Order #" + self.id.to_s + " approved by " + User.find(PaperTrail.whodunnit).name.to_s + "\n Item: " + self.name + ", $" + self.total_price.to_s
      end
    end

    event :submit do
      transitions :from => :approved, :to => :submitted
      after do
        @@notifier.ping "Order #" + self.id.to_s + " submitted to CHBE stores by " + User.find(PaperTrail.whodunnit).name.to_s + "\n Item: " + self.name + ", $" + self.total_price.to_s
      end
    end

    event :order do
      transitions :from => :submitted, :to => :ordered
      after do
        @@notifier.ping "Order #" + self.id.to_s + " ordered through CHBE stores - " + User.find(PaperTrail.whodunnit).name.to_s + "\n Item: " + self.name + ", $" + self.total_price.to_s
      end
    end

    event :receive do
      transitions :from => :ordered, :to => :received
      after do
        @@notifier.ping "Order #" + self.id.to_s + " received by " + User.find(PaperTrail.whodunnit).name.to_s + "\n Item: " + self.name + ", $" + self.total_price.to_s
      end
    end

    event :undo do
      transitions :from => :received, :to => :ordered
      after do
        @@notifier.ping "Order #" + self.id.to_s + " undo-ed status to 'ordered' by " + User.find(PaperTrail.whodunnit).name.to_s + "\n Item: " + self.name + ", $" + self.total_price.to_s
      end
    end

    event :reject do
      transitions :from => [:pending, :approved, :submitted, :ordered], :to => :rejected
      after do
        @@notifier.ping "Order #" + self.id.to_s + " rejected by " + User.find(PaperTrail.whodunnit).name.to_s + "\n Item: " + self.name + ", $" + self.total_price.to_s
      end
    end

  end

  extend Enumerize
  enumerize :aasm_state, in: aasm.states

  rails_admin do
    include_all_fields
    configure :aasm_state do
      read_only true
    end
    field :aasm_state, :enum do
      enum do
        bindings[:object].aasm.states(:permitted => true).map(&:name)
      end
    end
    list do
      scopes [nil, 'pending', 'approved', 'submitted', 'ordered', 'received', 'rejected']
    end
  end

end

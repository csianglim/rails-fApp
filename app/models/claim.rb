class Claim < ApplicationRecord
  has_paper_trail
  belongs_to :user, optional: false

  has_many :assets
  has_attached_file :asset
  validates_attachment_content_type :asset, content_type: ['image/jpeg', 'image/png', 'image/gif', 'application/pdf']

  delegate :name, :to => :user, :prefix => :user, :allow_nil => true
  validates :name, presence: true
  validates :user, presence: true
  validates :description, presence: true
  validates :amount, presence: true, numericality: true, :format => { :with => /\A\d+\.*\d{0,2}\z/ }
  validates :vendor, presence: true
  validates :category, presence: true
  validates :aasm_state, presence: true

  scope :pending,   ->{ where(aasm_state: 'pending')  }
  scope :approved,  ->{ where(aasm_state: 'approved')  }
  scope :submitted,  ->{ where(aasm_state: 'ordered')  }
  scope :received,   ->{ where(aasm_state: 'received')  }
  scope :rejected,   ->{ where(aasm_state: 'rejected')  }

  @@notifier = Slack::Notifier.new ENV["WEBHOOK_URL"] do
    defaults channel: "#logistics",
             username: "fApper - Claims"
  end

  def after_import_save(record)
    self.update_attribute(:user_id, PaperTrail.whodunnit)
    @@notifier.post text: "Claim #" + self.id.to_s + " awaiting approval. \nClaim created by " + User.find(PaperTrail.whodunnit).name.to_s + " - " + self.name.to_s + ": $" + self.amount.to_s
  end

  def create_associated_image(asset)
    assets.create(asset: asset)
  end

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
    field :amount do
      formatted_value do # used in form views
        number_to_currency(value, :unit => "$")
      end
      pretty_value do # used in form views
        number_to_currency(value, :unit => "$")
      end
    end
    list do
      scopes [nil, 'pending', 'approved', 'submitted', 'received', 'rejected']
    end
  end

  include AASM
  aasm do
    state :pending, :initial => true
    state :approved
    state :submitted
    state :received
    state :rejected

    event :approve do
      transitions :from => [:pending, :rejected], :to => :approved
      after do
        @@notifier.ping "Claim #" + self.id.to_s + " approved by " + self.user.name + "\n Item: " + self.name + ", $" + self.amount.to_s
      end
    end

    event :submit do
      transitions :from => :approved, :to => :submitted
      after do
        @@notifier.ping "Claim #" + self.id.to_s + " submitted by " + self.user.name + "\n Item: " + self.name + ", $" + self.amount.to_s
      end
    end

    event :receive do
      transitions :from => :submitted, :to => :received
      after do
        @@notifier.ping "Claim #" + self.id.to_s + " received by " + self.user.name + "\n Item: " + self.name + ", $" + self.amount.to_s
      end
    end

    event :undo do
      transitions :from => :received, :to => :submitted
      after do
        @@notifier.ping "Claim #" + self.id.to_s + " undo-ed state to 'submitted' by " + self.user.name + "\n Item: " + self.name + ", $" + self.amount.to_s
      end
    end

    event :reject do
      transitions :from => [:pending, :approved, :submitted], :to => :rejected
      after do
        @@notifier.ping "Claim #" + self.id.to_s + " rejected by " + self.user.name + "\n Item: " + self.name + ", $" + self.amount.to_s
      end
    end
  end

  extend Enumerize
  enumerize :aasm_state, in: aasm.states

end

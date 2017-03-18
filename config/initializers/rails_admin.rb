RailsAdmin.config do |config|
  include ActionView::Helpers::NumberHelper
  config.main_app_name = Proc.new { |controller| [ "fAPP: ", "Finance App" ] }

  ### Popular gems integration
  PAPER_TRAIL_AUDIT_MODEL = ['Order', 'Claim', 'Sale']

  # == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    # bulk_delete
    show
    edit
    # delete
    # show_in_app
    state
    history_index
    history_show

    config.model Claim do
      show do
        field :name
        field :description
        field :category
        field :vendor
        field :amount do
          formatted_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
          pretty_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
        end
        field :asset do
          visible do
            bindings[:controller].current_user.manager_role?
          end
          formatted_value do
            bindings[:view].tag(:a, href: bindings[:object].asset.url(:original)) << "Download"
          end
        end
      end
      export do
        field :name
        field :description
        field :category
        field :vendor
        field :amount
      end
      import do
        field :name
        field :description
        field :category
        field :vendor
        field :amount
      end
      list do
        field :id
        field :name
        field :user_name do
          label "Requested By"
        end
        field :amount do
          formatted_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
          pretty_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
        end
        field :asset do
          visible do
            bindings[:controller].current_user.manager_role?
          end
          formatted_value do
            bindings[:view].tag(:a, href: bindings[:object].asset.url(:original), target:"_blank") << "Download"
          end
        end
        field :aasm_state, :state do
          label "State"
        end
      end
      edit do
        field :name
        field :description
        field :category
        field :vendor
        field :amount do
          formatted_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
          pretty_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
        end
        field :asset, :paperclip
        configure :aasm_state do
          visible false
        end
        configure :user do
          visible false
        end
        field :user_id, :hidden do
          visible true
          default_value do
            bindings[:view]._current_user.id
          end
        end
      end
      state({
        events: {reject: 'btn-danger', approve: 'btn-success', submit: 'btn-warning', receive: 'btn-primary'},
        states: {pending: 'label-default', approved: 'label-success', rejected: 'label-danger', submitted: 'label-warning', received:'label-primary'},
        disable: []
      })
    end

    config.model Sale do
      edit do
        include_all_fields
        exclude_fields :aasm_state
      end
    end

    config.model Order do
      list do
        field :id
        field :name do
          pretty_value do
            %{<a target="_blank" href="#{bindings[:object].link}">#{bindings[:object].name}</a>}.html_safe
          end
        end
        # field :user_name do
        #   label "Requested By"
        # end
        field :supplier
        # field :account
        field :total_price do
          formatted_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
          pretty_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
        end
        field :aasm_state, :state do
          label "State"
        end
        field :comments
        # field :link do
        #   formatted_value do
        #     bindings[:view].tag(:a, href: bindings[:object].link, target:"_blank") << "Link"
        #   end
        # end
        # field :updated_at do
        #   date_format :short
        #   label "Last Updated"
        # end
      end

      show do
        field :account
        include_all_fields
        configure :total_price do
          formatted_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
          pretty_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
        end
        configure :price do
          formatted_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
          pretty_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
        end
      end

      edit do
        include_all_fields
        exclude_fields :aasm_state
        # configure :user do
        #   visible false
        # end
        # field :user_id, :hidden do
        #   visible true
        #   default_value do
        #     bindings[:view]._current_user.id
        #   end
        # end
      end
      state({
        events: {reject: 'btn-danger', approve: 'btn-success', submit: 'btn-warning', order: 'btn-info', receive: 'btn-primary'},
        states: {pending: 'label-default', submit: 'label-warning', rejected: 'label-danger', ordered: 'label-info', approved: 'label-success', received:'label-primary'},
        disable: []
      })
    end

    config.model Account do
      list do
        field :id
        field :name
        field :amount do
          formatted_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
          pretty_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
        end
        field :updated_at do
          date_format :short
          label "Last Updated"
        end
      end
      show do
        configure :amount do
          formatted_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
          pretty_value do # used in form views
            number_to_currency(value, :unit => "$")
          end
        end
      end
      edit do
        include_all_fields
      end
    end


  end
end

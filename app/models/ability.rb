class Ability
  include CanCan::Ability

  def initialize(user)

   # Define abilities for the passed in user here. For example:
    user ||= User.new # guest user (not logged in)

    can :access, :rails_admin
    can :dashboard
    can :read, [Order, Claim]

    if user.user_role?
      cannot :read, [User, Account]
      cannot :destroy, :all
      cannot :update, :all
    else
      if user.manager_role?
        can :import, Order
      end
      if user.superadmin_role?
        can :read, :all
        can :manage, :all
        can :import, :all
        can :state
        can :all_events
        can :destroy, :all
      elsif user.supervisor_role?
        can :manage, [Order, Claim, Sale, Account, User]
      elsif user.approver_role?
        can :manage, [Order, Claim, Sale, Account]
        can :state
        can :all_events
      elsif user.logistics_role?
        can :manage, [Order, Claim, Sale, Account]
        can :state, [Order, Claim]
        can :all_events, [Order, Claim]
        cannot :state, Order, :pending? => true
        cannot :all_events, Order, :pending? => true
      end
    end
  end
end

module Invitational
  class Invitation < ActiveRecord::Base
    attr_accessible :email,
      :role,
      :invitable,
      :user

    belongs_to :user, :class_name => Invitational.user_class.to_s
    belongs_to :invitable, :polymorphic => true

    validates :email,  :presence => true
    validates :role,  :presence => true
    validates :invitable,  :presence => true

    scope :for_email, lambda {|email|
      where('email = ?', email)
    }

    scope :pending_for, lambda {|email|
      where('email = ? AND user_id IS NULL', email)
    }

    scope :for_claim_hash, lambda {|claim_hash|
      where('claim_hash = ?', claim_hash)
    }

    scope :for_invitable, lambda {|type, id|
      where('invitable_type = ? AND invitable_id = ?', type, id)
    }

    scope :by_role, lambda {|role|
      where('role = ?', role)
    }

    scope :pending, where('user_id IS NULL')
    scope :claimed, where('user_id IS NOT NULL')

    def user= user
      if user.nil?
        self.date_accepted = nil
      else
        self.date_accepted = DateTime.now
      end

      super user
    end

    def save
      if id.nil?
        self.date_sent = DateTime.now
        self.claim_hash = Digest::SHA1.hexdigest(email + date_sent.to_s)
      end

      super
    end

    def role_title
      InvitationRoles::ROLES[role]
    end

    def claimed?
      user.nil? == false
    end

    def unclaimed?
      !claimed?
    end

  end
end


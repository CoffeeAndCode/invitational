module Invitational
  class ChecksForInvitation

    def self.for user, invitable, roles=nil
      self.uber_admin?(user) || self.specific_invite?(user, invitable, roles)
    end

private 

    def self.uber_admin? user
      user.invitations.uber_admin.count == 1
    end

    def self.specific_invite? user, invitable, roles
      invites = user.invitations.for_invitable(invitable.class.name, invitable.id)

      if invites.count > 0
        unless roles.nil?
          self.role_check invites.first, roles
        else
          true
        end
      end
    end

    def self.role_check invitation, roles
      if roles.respond_to? :map
        role_numbers = roles.map {|role| Invitational::Role[role]}
        role_numbers.include? invitation.role.to_i
      else
        invitation.role.to_i == Invitational::Role[roles]
      end
    end

  end
end

#
# Used to store a (symmetrically) encrypted string in Mongo
#
# Usage:
# field :social_security_number, type: Mongoid::EncryptedString
#
# Set with an unencrypted string
# p = Person.new()
# p.social_security_number = '123456789'
#
# Get returns the unencrypted string
# puts p.social_security_number -> '123456789'
#
# Use the encrypted property to see the encrypted value
# puts p.social_security_number.encrypted -> '....'
#
module Mongoid
  class EncryptedString < String
    include EncryptedField

    class << self

      # Get the object as it was stored in the database, and instantiate this custom class from it.
      def demongoize(object)
        case
          when object.is_a?(EncryptedDate) || object.blank?
            object
          else
            EncryptedString.new(object.decrypt(:symmetric))
        end
      end

      # Takes any possible object and converts it to how it would be stored in the database.
      def mongoize(object)
        case
          when object.is_a?(EncryptedString)
            object.mongoize
          when is_encrypted?(object) || (object.to_s.empty?)
            object
          else
            EncryptedString.new(object).mongoize unless object.blank?
        end
      end

      # Converts the object that was supplied to a criteria and converts it into a database friendly form.
      alias_method :evolve, :mongoize

    end
  end
end

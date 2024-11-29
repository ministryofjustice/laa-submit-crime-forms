module Search
  class Result < SimpleDelegator
    # This could be instantiated either with a ListRow or a Claim or a PriorAuthorityApplication

    def last_state_change
      updated_at
    end

    def client_name
      case __getobj__
      when ListRow
        (main_defendant || defendant).full_name
      when Claim
        main_defendant.full_name
      when PriorAuthorityApplication
        defendant.full_name
      else
        raise "Don't know how to extract client_name from #{__getobj__.class}"
      end
    end

    def account_number
      office_code
    end

    def status_with_assignment
      case state
      when 'auto_grant'
        'granted'
      else
        state
      end
    end

    def draft?
      state == 'draft'
    end
  end
end

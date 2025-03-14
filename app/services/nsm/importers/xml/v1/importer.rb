module Nsm
  module Importers
    module Xml
      module V1
        class Importer
          attr_accessor :claim, :hash

          def initialize(claim, hash)
            @claim = claim
            @hash = hash
          end

          def call
            resolve_reasons_for_claim
            enhanced_rates_if_uplifts
            populate_has_disbursements

            create_work_items
            create_defendants
            create_disbursements
            create_firm_office
            create_solicitor

            claim.update(hash)
          end

          def create_work_items
            return unless hash['work_items']

            work_items = hash.delete('work_items')
            claim.work_items.create(work_items['work_item'])
          rescue StandardError
            # pass through
          end

          def create_disbursements
            return unless hash['disbursements']

            disbursements = hash.delete('disbursements')
            claim.disbursements.create(disbursements['disbursement'])
          rescue StandardError
            # pass through
          end

          def create_defendants
            return unless hash['defendants']

            defendants = hash.delete('defendants')
            main_defendant = defendants['defendant'].select { _1['main'] == 'true' }
            return if main_defendant.count > 1 || main_defendant.empty?

            sorted = defendants['defendant'].sort_by { _1['main'] == 'true' ? 0 : 1 }

            sorted = sorted.each_with_index do |defendant, index|
              defendant['position'] = index + 1
            end

            claim.defendants.create(sorted)
          rescue StandardError
            # pass through
          end

          def create_firm_office
            return unless hash['firm_office']

            claim.create_firm_office(hash.delete('firm_office'))
          rescue StandardError
            # pass through
          end

          def create_solicitor
            return unless hash['solicitor']

            claim.create_solicitor(hash.delete('solicitor'))
          rescue StandardError
            # pass through
          end

          def resolve_reasons_for_claim
            hash['reasons_for_claim'] = hash['reasons_for_claim']['reason']
          end

          def populate_has_disbursements
            hash['has_disbursements'] = hash['disbursements'].present? ? 'yes' : 'no'
          end

          def enhanced_rates_if_uplifts
            work_uplift = hash.dig('work_items', 'work_item')&.detect { _1['uplift'].present? }
            uplifts = work_uplift || hash['calls_uplift'].present? || hash['letters_uplift'].present?
            hash['reasons_for_claim'] << 'enhanced_rates_claimed' if uplifts
          end
        end
      end
    end
  end
end

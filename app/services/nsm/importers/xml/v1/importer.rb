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
            create_work_items
            create_defendants
            create_disbursements
            create_firm_office
            create_solicitor
            resolve_reasons_for_claim

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
            claim.defendants.create(defendants['defendant'])
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
        end
      end
    end
  end
end

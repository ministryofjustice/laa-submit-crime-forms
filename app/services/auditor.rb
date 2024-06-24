class Auditor
  def initialize(office_codes, since)
    @office_codes = office_codes
    @since = since
  end

  def call
    @output = ''

    list_providers
    list_updated_claims
    list_updated_applications
    list_updated_documents

    @output
  end

  private

  def list_providers
    append '==============================='
    append '| Provider accounts affected: |'
    append '==============================='
    append_table matching_providers, [:email]
  end

  def list_updated_claims
    append '======================='
    append '| NSM claims updated: |'
    append '======================='
    append_table updated_claims, [:id, :status]
  end

  def list_updated_applications
    append '============================'
    append '| PA applications updated: |'
    append '============================'
    append_table updated_applications, [:id, :status]
  end

  def list_updated_documents
    append '===================='
    append '| Documents added: |'
    append '===================='
    append_table updated_documents, [:file_name, :documentable_id, :documentable_type]
  end

  def append(string)
    @output += "#{string}\n"
  end

  def append_table(collection, columns)
    append TablePrint::Printer.new(collection, columns).table_print
    append "\n"
  end

  def matching_providers
    Provider.where('to_jsonb(office_codes) ?| array[:q]', q: @office_codes)
  end

  def updated_claims
    clause = %i[claims firm_offices solicitors defendants work_items disbursements].map { "#{_1}.updated_at > :since" }
                                                                                   .join(' OR ')
    matching_claims
      .left_joins(:firm_office, :solicitor, :defendants, :work_items, :disbursements)
      .where(clause, since: @since)
      .uniq
  end

  def updated_applications
    clause = %i[prior_authority_applications firm_offices solicitors
                defendants quotes additional_costs further_informations
                incorrect_informations].map { "#{_1}.updated_at > :since" }
             .join(' OR ')
    matching_applications
      .left_joins(:firm_office,
                  :solicitor,
                  :defendant,
                  :quotes,
                  :additional_costs,
                  :further_informations,
                  :incorrect_informations)
      .where(clause, since: @since)
      .uniq
  end

  def matching_claims
    Claim.where(office_code: @office_codes)
         .or(Claim.where(submitter: matching_providers))
  end

  def matching_applications
    PriorAuthorityApplication.where(office_code: @office_codes)
                             .or(PriorAuthorityApplication.where(provider: matching_providers))
  end

  def updated_documents
    SupportingDocument.where(documentable_id: matching_documentables, updated_at: @since..)
  end

  def matching_documentables
    [matching_claims, matching_applications, matching_quotes, matching_further_informations].map { _1.pluck(:id) }
                                                                                            .flatten
                                                                                            .uniq
  end

  def matching_quotes
    Quote.where(prior_authority_application: matching_applications)
  end

  def matching_further_informations
    FurtherInformation.where(prior_authority_application: matching_applications)
  end
end

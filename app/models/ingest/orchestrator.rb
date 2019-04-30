module Ingest
  class Orchestrator
    ##
    # Given a +submission_file+ perform the complete ingest process
    #
    # This includes updating the +submission+ model with the correct
    # states throughout the process
    def initialize(submission_file)
      @submission_file = submission_file
      @submission = @submission_file.submission
      @framework = @submission.framework
    end

    def perform
      # Remove after testing
      SubmissionEntry.where(submission_file_id: @submission_file.id).delete_all if Rails.env.development?
      # Remove after testing

      Rails.logger.tagged(logger_tags) do
        @submission.update!(aasm_state: :processing)

        download = Ingest::SubmissionFileDownloader.new(@submission_file).perform
        return unless download.downloaded?

        converter = Ingest::Converter.new(download)
        @submission_file.update!(rows: converter.rows)

        loader = Ingest::Loader.new(converter, @submission_file)
        loader.perform

        @submission.ready_for_review!
      end
    end

    private

    def logger_tags
      [
        @submission_file.id,
        @framework.short_name,
        'ingest'
      ]
    end
  end
end
module Backup::Syncer::Duplicity
  class S3 < Base
    attr_accessor :bucket

    def initialize(syncer_id = nil)
      super
    end

    def perform!
      log!(:started)

      run(duplicity_command)

      log!(:finished)
    end

    def s3_url
      File.join("s3+http://#{bucket}", "#{path}")
    end

    def duplicity_command
      [
        'duplicity',
        '--s3-use-multiprocessing',
        '--s3-use-new-style',
        '--progress',
        '--null-separator',
        '--no-encryption',
        '--exclude **/vendor',
        '--exclude **/node_modules',
        paths_to_push,
        "'#{s3_url}'"].join(" ")
    end
  end
end

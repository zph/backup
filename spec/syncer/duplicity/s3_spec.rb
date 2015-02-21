# encoding: utf-8

require File.expand_path('../../../spec_helper.rb', __FILE__)

module Backup
  describe Syncer::Duplicity::S3 do
    KLASS = Syncer::Duplicity::S3
    # before do
    #   KLASS.any_instance.
    #       stubs(:utility).with(:rsync).returns('rsync')
    #   Syncer::RSync::Push.any_instance.
    #       stubs(:utility).with(:ssh).returns('ssh')
    # end

    describe '#initialize' do
      after { KLASS.clear_defaults! }

      it 'should use the values given' do
        syncer = KLASS.new('my syncer') do |d|
          d.path            = "~/my_backups/"

          d.directories do |directory|
            directory.add '/some/directory/'
            # directory.exclude '*~'
          end
        end

        expect( syncer.path           ).to eq '~/my_backups/'
        expect( syncer.directories ).to eq ['/some/directory/']
        # expect( syncer.excludes    ).to eq ['*~', 'tmp/']
      end
    end

    describe '#perform!' do

      specify 'basic connection' do

        source_folder = "/local/folder/to/push"
        amazon_bucket = "s3_bucket"
        destination_dir = "s3/folder"
        s3_url= File.join("s3+http://#{amazon_bucket}", "#{destination_dir}")

        syncer = KLASS.new do |s|
          s.bucket = amazon_bucket
          s.path = destination_dir
          s.directories do |dirs|
            dirs.add source_folder
          end
        end

        # syncer.expects(:run).with(<<-CMD.chomp
# duplicity \
  # --s3-use-multiprocessing \
  # --s3-use-new-style \
  # --progress \
  # --null-separator \
  # --no-encryption \
  # --exclude **/vendor \
  # --exclude **/node_modules \
  # '#{File.expand_path source_folder}' \
  # "#{s3_url}"
# CMD
        # )
        # syncer.perform!
        expect(syncer.array_command).to eq([
        'duplicity',
        '--s3-use-multiprocessing',
        '--s3-use-new-style',
        '--progress',
        '--null-separator',
        '--no-encryption',
        '--exclude **/vendor',
        '--exclude **/node_modules',
        "#{File.expand_path(source_folder).shellescape}",
        "'#{s3_url}'"].join(" ")
        )
      end
      #   specify 'with both' do
      #     syncer = Syncer::RSync::Push.new do |s|
      #       s.mode = :ssh
      #       s.host = 'my_host'
      #       s.ssh_user = 'ssh_username'
      #       s.mirror = true
      #       s.compress = true
      #       s.path = '~/path/in/remote/home/'
      #       s.directories do |dirs|
      #         dirs.add '/this/dir/'
      #         dirs.add 'that/dir'
      #       end
      #     end

      #     syncer.expects(:create_dest_path!)
      #     syncer.expects(:run).with(
      #       "rsync --archive --delete --compress " +
      #       "-e \"ssh -p 22 -l ssh_username\" " +
      #       "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #       "my_host:'path/in/remote/home'"
      #     )
      #     syncer.perform!
      #   end

      #   specify 'without mirror' do
      #     syncer = Syncer::RSync::Push.new do |s|
      #       s.mode = :ssh
      #       s.host = 'my_host'
      #       s.ssh_user = 'ssh_username'
      #       s.compress = true
      #       s.path = 'relative/path/in/remote/home'
      #       s.directories do |dirs|
      #         dirs.add '/this/dir/'
      #         dirs.add 'that/dir'
      #       end
      #     end

      #     syncer.expects(:create_dest_path!)
      #     syncer.expects(:run).with(
      #       "rsync --archive --compress " +
      #       "-e \"ssh -p 22 -l ssh_username\" " +
      #       "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #       "my_host:'relative/path/in/remote/home'"
      #     )
      #     syncer.perform!
      #   end

      #   specify 'without compress' do
      #     syncer = Syncer::RSync::Push.new do |s|
      #       s.mode = :ssh
      #       s.host = 'my_host'
      #       s.mirror = true
      #       s.path = '/absolute/path/on/remote/'
      #       s.directories do |dirs|
      #         dirs.add '/this/dir/'
      #         dirs.add 'that/dir'
      #       end
      #     end

      #     syncer.expects(:create_dest_path!)
      #     syncer.expects(:run).with(
      #       "rsync --archive --delete " +
      #       "-e \"ssh -p 22\" " +
      #       "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #       "my_host:'/absolute/path/on/remote'"
      #     )
      #     syncer.perform!
      #   end

      #   specify 'without both' do
      #     syncer = Syncer::RSync::Push.new do |s|
      #       s.mode = :ssh
      #       s.host = 'my_host'
      #       s.path = '/absolute/path/on/remote'
      #       s.directories do |dirs|
      #         dirs.add '/this/dir/'
      #         dirs.add 'that/dir'
      #       end
      #     end

      #     syncer.expects(:create_dest_path!)
      #     syncer.expects(:run).with(
      #       "rsync --archive " +
      #       "-e \"ssh -p 22\" " +
      #       "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #       "my_host:'/absolute/path/on/remote'"
      #     )
      #     syncer.perform!
      #   end

      # end # describe 'mirror and compress options'

      # describe 'additional_rsync_options' do

      #   specify 'given as an Array (with mirror option)' do
      #     syncer = Syncer::RSync::Push.new do |s|
      #       s.mode = :ssh
      #       s.host = 'my_host'
      #       s.mirror = true
      #       s.additional_rsync_options = ['--opt-a', '--opt-b']
      #       s.path = 'path/on/remote/'
      #       s.directories do |dirs|
      #         dirs.add '/this/dir'
      #         dirs.add 'that/dir'
      #       end
      #     end

      #     syncer.expects(:create_dest_path!)
      #     syncer.expects(:run).with(
      #       "rsync --archive --delete --opt-a --opt-b " +
      #       "-e \"ssh -p 22\" " +
      #       "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #       "my_host:'path/on/remote'"
      #     )
      #     syncer.perform!
      #   end

      #   specify 'given as a String (without mirror option)' do
      #     syncer = Syncer::RSync::Push.new do |s|
      #       s.mode = :ssh
      #       s.host = 'my_host'
      #       s.additional_rsync_options = '--opt-a --opt-b'
      #       s.path = 'path/on/remote/'
      #       s.directories do |dirs|
      #         dirs.add '/this/dir/'
      #         dirs.add 'that/dir'
      #       end
      #     end

      #     syncer.expects(:create_dest_path!)
      #     syncer.expects(:run).with(
      #       "rsync --archive --opt-a --opt-b " +
      #       "-e \"ssh -p 22\" " +
      #       "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #       "my_host:'path/on/remote'"
      #     )
      #     syncer.perform!
      #   end

      #   specify 'with excludes' do
      #     syncer = Syncer::RSync::Push.new do |s|
      #       s.mode = :ssh
      #       s.host = 'my_host'
      #       s.additional_rsync_options = '--opt-a --opt-b'
      #       s.path = 'path/on/remote/'
      #       s.directories do |dirs|
      #         dirs.add '/this/dir/'
      #         dirs.add 'that/dir'
      #         dirs.exclude '*~'
      #         dirs.exclude 'tmp/'
      #       end
      #     end

      #     syncer.expects(:create_dest_path!)
      #     syncer.expects(:run).with(
      #       "rsync --archive --exclude='*~' --exclude='tmp/' --opt-a --opt-b " +
      #       "-e \"ssh -p 22\" " +
      #       "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #       "my_host:'path/on/remote'"
      #     )
      #     syncer.perform!
      #   end

      # end # describe 'additional_rsync_options'

      # describe 'rsync password options' do
      #   let(:s) { sequence '' }
      #   let(:password_file) { mock }

      #   context 'when an rsync_password is given' do
      #     let(:syncer) {
      #       Syncer::RSync::Push.new do |syncer|
      #         syncer.mode = :rsync_daemon
      #         syncer.host = 'my_host'
      #         syncer.rsync_user = 'rsync_username'
      #         syncer.rsync_password = 'my_password'
      #         syncer.mirror = true
      #         syncer.compress = true
      #         syncer.path = 'my_module'
      #         syncer.directories do |dirs|
      #           dirs.add '/this/dir'
      #           dirs.add 'that/dir'
      #         end
      #       end
      #     }

      #     before do
      #       password_file.stubs(:path).returns('path/to/password_file')
      #       Tempfile.expects(:new).in_sequence(s).
      #           with('backup-rsync-password').returns(password_file)
      #       password_file.expects(:write).in_sequence(s).with('my_password')
      #       password_file.expects(:close).in_sequence(s)
      #     end

      #     it 'creates and uses a temp file for the password' do
      #       syncer.expects(:run).in_sequence(s).with(
      #         "rsync --archive --delete --compress " +
      #         "--password-file='#{ File.expand_path('path/to/password_file') }' " +
      #         "--port 873 " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "rsync_username@my_host::'my_module'"
      #       )

      #       password_file.expects(:delete).in_sequence(s)

      #       syncer.perform!
      #     end

      #     it 'ensures tempfile removal' do
      #       syncer.expects(:run).in_sequence(s).raises('error message')

      #       password_file.expects(:delete).in_sequence(s)

      #       expect do
      #         syncer.perform!
      #       end.to raise_error(RuntimeError, 'error message')
      #     end
      #   end # context 'when an rsync_password is given'

      #   context 'when an rsync_password_file is given' do
      #     let(:syncer) {
      #       Syncer::RSync::Push.new do |syncer|
      #         syncer.mode = :ssh_daemon
      #         syncer.host = 'my_host'
      #         syncer.ssh_user = 'ssh_username'
      #         syncer.rsync_user = 'rsync_username'
      #         syncer.rsync_password_file = 'path/to/my_password'
      #         syncer.mirror = true
      #         syncer.compress = true
      #         syncer.path = 'my_module'
      #         syncer.directories do |dirs|
      #           dirs.add '/this/dir'
      #           dirs.add 'that/dir'
      #         end
      #       end
      #     }

      #     before do
      #       Tempfile.expects(:new).never
      #     end

      #     it 'uses the given path' do
      #       syncer.expects(:run).in_sequence(s).with(
      #         "rsync --archive --delete --compress " +
      #         "--password-file='#{ File.expand_path('path/to/my_password') }' " +
      #         "-e \"ssh -p 22 -l ssh_username\" " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "rsync_username@my_host::'my_module'"
      #       )
      #       syncer.perform!
      #     end
      #   end # context 'when an rsync_password_file is given'

      #   context 'when using :ssh mode' do
      #     let(:syncer) {
      #       Syncer::RSync::Push.new do |syncer|
      #         syncer.mode = :ssh
      #         syncer.host = 'my_host'
      #         syncer.ssh_user = 'ssh_username'
      #         syncer.rsync_user = 'rsync_username'
      #         syncer.rsync_password = 'my_password'
      #         syncer.rsync_password_file = 'path/to/my_password'
      #         syncer.mirror = true
      #         syncer.compress = true
      #         syncer.path = '~/path/in/remote/home'
      #         syncer.directories do |dirs|
      #           dirs.add '/this/dir'
      #           dirs.add 'that/dir'
      #         end
      #       end
      #     }

      #     before do
      #       Tempfile.expects(:new).never
      #     end

      #     it 'uses no rsync_user, tempfile or password_option' do
      #       syncer.expects(:create_dest_path!)
      #       syncer.expects(:run).in_sequence(s).with(
      #         "rsync --archive --delete --compress " +
      #         "-e \"ssh -p 22 -l ssh_username\" " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "my_host:'path/in/remote/home'"
      #       )
      #       syncer.perform!
      #     end
      #   end # context 'when an rsync_password_file is given'

      # end # describe 'rsync password options'

      # describe 'transport_options and host_command' do

      #   context 'using :rsync_daemon mode' do

      #     it 'uses the rsync --port option' do
      #       syncer = Syncer::RSync::Push.new do |s|
      #         s.mode = :rsync_daemon
      #         s.host = 'my_host'
      #         s.mirror = true
      #         s.compress = true
      #         s.additional_rsync_options = '--opt-a --opt-b'
      #         s.path = 'module_name/path/'
      #         s.directories do |dirs|
      #           dirs.add '/this/dir/'
      #           dirs.add 'that/dir'
      #         end
      #       end

      #       syncer.expects(:run).with(
      #         "rsync --archive --delete --opt-a --opt-b --compress " +
      #         "--port 873 " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "my_host::'module_name/path'"
      #       )
      #       syncer.perform!
      #     end

      #     it 'uses the rsync_user' do
      #       syncer = Syncer::RSync::Push.new do |s|
      #         s.mode = :rsync_daemon
      #         s.host = 'my_host'
      #         s.port = 789
      #         s.rsync_user = 'rsync_username'
      #         s.mirror = true
      #         s.additional_rsync_options = '--opt-a --opt-b'
      #         s.path = 'module_name/path/'
      #         s.directories do |dirs|
      #           dirs.add '/this/dir/'
      #           dirs.add 'that/dir'
      #         end
      #       end

      #       syncer.expects(:run).with(
      #         "rsync --archive --delete --opt-a --opt-b " +
      #         "--port 789 " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "rsync_username@my_host::'module_name/path'"
      #       )
      #       syncer.perform!
      #     end

      #   end # context 'in :rsync_daemon mode'

      #   context 'using :ssh_daemon mode' do

      #     specify 'rsync_user, additional_ssh_options as an Array' do
      #       syncer = Syncer::RSync::Push.new do |s|
      #         s.mode = :ssh_daemon
      #         s.host = 'my_host'
      #         s.mirror = true
      #         s.compress = true
      #         s.additional_ssh_options = ['--opt1', '--opt2']
      #         s.rsync_user = 'rsync_username'
      #         s.additional_rsync_options = '--opt-a --opt-b'
      #         s.path = 'module_name/path/'
      #         s.directories do |dirs|
      #           dirs.add '/this/dir/'
      #           dirs.add 'that/dir'
      #         end
      #       end

      #       syncer.expects(:run).with(
      #         "rsync --archive --delete --opt-a --opt-b --compress " +
      #         "-e \"ssh -p 22 --opt1 --opt2\" " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "rsync_username@my_host::'module_name/path'"
      #       )
      #       syncer.perform!
      #     end

      #     specify 'ssh_user, port, additional_ssh_options as an String' do
      #       syncer = Syncer::RSync::Push.new do |s|
      #         s.mode = :ssh_daemon
      #         s.host = 'my_host'
      #         s.port = 789
      #         s.mirror = true
      #         s.compress = true
      #         s.ssh_user = 'ssh_username'
      #         s.additional_ssh_options = "-i '/my/identity_file'"
      #         s.additional_rsync_options = '--opt-a --opt-b'
      #         s.path = 'module_name/path/'
      #         s.directories do |dirs|
      #           dirs.add '/this/dir/'
      #           dirs.add 'that/dir'
      #         end
      #       end

      #       syncer.expects(:run).with(
      #         "rsync --archive --delete --opt-a --opt-b --compress " +
      #         "-e \"ssh -p 789 -l ssh_username -i '/my/identity_file'\" " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "my_host::'module_name/path'"
      #       )
      #       syncer.perform!
      #     end

      #   end # context 'in :ssh_daemon mode'

      #   context 'using :ssh mode' do

      #     it 'uses no daemon or rsync user' do
      #       syncer = Syncer::RSync::Push.new do |s|
      #         s.mode = :ssh
      #         s.host = 'my_host'
      #         s.mirror = true
      #         s.compress = true
      #         s.ssh_user = 'ssh_username'
      #         s.additional_ssh_options = ['--opt1', '--opt2']
      #         s.rsync_user = 'rsync_username'
      #         s.additional_rsync_options = "--opt-a 'something'"
      #         s.path = '~/some/path/'
      #         s.directories do |dirs|
      #           dirs.add '/this/dir/'
      #           dirs.add 'that/dir'
      #         end
      #       end

      #       syncer.expects(:create_dest_path!)
      #       syncer.expects(:run).with(
      #         "rsync --archive --delete --opt-a 'something' --compress " +
      #         "-e \"ssh -p 22 -l ssh_username --opt1 --opt2\" " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "my_host:'some/path'"
      #       )
      #       syncer.perform!
      #     end

      #   end # context 'in :ssh mode'

      # end # describe 'transport_options and host_command'

      # describe 'dest_path creation' do
      #   context 'when using :ssh mode' do
      #     it 'creates path using ssh with transport args' do
      #       syncer = Syncer::RSync::Push.new do |s|
      #         s.mode = :ssh
      #         s.host = 'my_host'
      #         s.ssh_user = 'ssh_username'
      #         s.additional_ssh_options = "-i '/path/to/id_rsa'"
      #         s.path = '~/some/path/'
      #         s.directories do |dirs|
      #           dirs.add '/this/dir/'
      #           dirs.add 'that/dir'
      #         end
      #       end

      #       syncer.expects(:run).with(
      #         "ssh -p 22 -l ssh_username -i '/path/to/id_rsa' my_host " +
      #         %q["mkdir -p 'some/path'"]
      #       )

      #       syncer.expects(:run).with(
      #         "rsync --archive " +
      #         "-e \"ssh -p 22 -l ssh_username -i '/path/to/id_rsa'\" " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "my_host:'some/path'"
      #       )

      #       syncer.perform!
      #     end

      #     it 'only creates path if mkdir -p is required' do
      #       syncer = Syncer::RSync::Push.new do |s|
      #         s.mode = :ssh
      #         s.host = 'my_host'
      #         s.ssh_user = 'ssh_username'
      #         s.additional_ssh_options = "-i '/path/to/id_rsa'"
      #         s.path = '~/path/'
      #         s.directories do |dirs|
      #           dirs.add '/this/dir/'
      #           dirs.add 'that/dir'
      #         end
      #       end

      #       syncer.expects(:run).with(
      #         "rsync --archive " +
      #         "-e \"ssh -p 22 -l ssh_username -i '/path/to/id_rsa'\" " +
      #         "'/this/dir' '#{ File.expand_path('that/dir') }' " +
      #         "my_host:'path'"
      #       )

      #       syncer.perform!
      #     end
      #   end
      # end # describe 'dest_path creation'

      # describe 'logging messages' do
      #   it 'logs started/finished messages' do
      #     syncer = Syncer::RSync::Push.new

      #     Logger.expects(:info).with('Syncer::RSync::Push Started...')
      #     Logger.expects(:info).with('Syncer::RSync::Push Finished!')
      #     syncer.perform!
      #   end

      #   it 'logs messages using optional syncer_id' do
      #     syncer = Syncer::RSync::Push.new('My Syncer')

      #     Logger.expects(:info).with('Syncer::RSync::Push (My Syncer) Started...')
      #     Logger.expects(:info).with('Syncer::RSync::Push (My Syncer) Finished!')
      #     syncer.perform!
      #   end
      # end

    end # describe '#perform!'

  end
end

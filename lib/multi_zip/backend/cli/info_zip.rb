module MultiZip::Backend::Cli
  module InfoZip
    require 'stringio'
    require 'open3'

    BUFFER_SIZE = 8192

    ZIP_AND_UNZIP_ARE_SAME_PROGRAM = false

    ZIP_PROGRAM = 'zip'
    ZIP_PROGRAM_SIGNATURE = /This is Zip [2-3].\d+\s.+, by Info-ZIP/
    ZIP_PROGRAM_SIGNATURE_SWITCH = '-v'

    UNZIP_PROGRAM ='unzip'
    UNZIP_PROGRAM_SIGNATURE = /UnZip [5-6]\.\d+ of .+, by Info-ZIP/
    UNZIP_PROGRAM_SIGNATURE_SWITCH = '-v'
    UNZIP_PROGRAM_LIST_MEMBERS_SWITCHES = ['-Z', '-1']
    UNZIP_PROGRAM_READ_MEMBER_SWITCH = '-p'

    def self.require_name
      'info_zip'
    end

    def self.extend_class
      lambda { MultiZip::Backend::Cli::InfoZip::InstanceMethods }
    end

    def self.human_name
      'Info-ZIP - zip(1L)/unzip(1L)'
    end

    def self.available?
      @available ||= programs_found?    
    end

    def self.programs_found?
      if ZIP_AND_UNZIP_ARE_SAME_PROGRAM
        zip_program_found?
      else
        zip_program_found? && unzip_program_found?
      end
    end

    def self.zip_program_found?
      spawn([ZIP_PROGRAM, ZIP_PROGRAM_SIGNATURE_SWITCH]).first =~ ZIP_PROGRAM_SIGNATURE
    end

    def self.unzip_program_found?
      spawn([UNZIP_PROGRAM, UNZIP_PROGRAM_SIGNATURE_SWITCH]).first =~ UNZIP_PROGRAM_SIGNATURE
    end

    # Blatant copy from https://github.com/seamusabshere/unix_utils/blob/master/lib/unix_utils.rb
    def self.spawn(argv, options = {}) # :nodoc:
      input = if (read_from = options[:read_from])
        if RUBY_DESCRIPTION =~ /jruby 1.7.0/
          raise "MultiZip: Can't use `#{argv.first}` since JRuby 1.7.0 has a broken IO implementation!"
        end
        File.open(read_from, 'r')
      end
      output = if (write_to = options[:write_to])
        output_redirected = true
        File.open(write_to, 'wb')
      else
        output_redirected = false
        StringIO.new
      end
      error = StringIO.new
      if (chdir = options[:chdir])
        Dir.chdir(chdir) do
          _spawn argv, input, output, error
        end
      else
        _spawn argv, input, output, error
      end
      error.rewind
      whole_error = error.read
      unless whole_error.empty?
        $stderr.puts "MultiZip: `#{argv.join(' ')}` STDERR:"
        $stderr.puts whole_error
      end
      unless output_redirected
        output.rewind
        [output.read, whole_error].map{|o| o.empty? ? nil : o}
      end
    ensure
      [input, output, error].each { |io| io.close if io and not io.closed? }
    end

    # Blatant copy from https://github.com/seamusabshere/unix_utils/blob/master/lib/unix_utils.rb
    def self._spawn(argv, input, output, error)
      # lifted from posix-spawn
      # https://github.com/rtomayko/posix-spawn/blob/master/lib/posix/spawn/child.rb
      Open3.popen3(*argv) do |stdin, stdout, stderr|
        readers = [stdout, stderr]
        if RUBY_DESCRIPTION =~ /jruby 1.7.0/
          readers.delete stderr
        end
        writers = if input
          [stdin]
        else
          stdin.close
          []
        end
        while readers.any? or writers.any?
          ready = IO.select(readers, writers, readers + writers)
          # write to stdin stream
          ready[1].each do |fd|
            begin
              boom = nil
              size = fd.write input.read(BUFFER_SIZE)
            rescue Errno::EPIPE => boom
            rescue Errno::EAGAIN, Errno::EINTR
            end
            if boom || size < BUFFER_SIZE
              stdin.close
              input.close
              writers.delete stdin
            end
          end
          # read from stdout and stderr streams
          ready[0].each do |fd|
            buf = (fd == stdout) ? output : error
            if fd.eof?
              readers.delete fd
              fd.close
            else
              begin
                # buf << fd.gets(BUFFER_SIZE) # maybe?
                buf << fd.readpartial(BUFFER_SIZE)
              rescue Errno::EAGAIN, Errno::EINTR
              end
            end
          end
        end
        # thanks @tmm1 and @rtomayko for showing how it's done!
      end
    end

    module InstanceMethods
      def list_members(prefix = nil, options={})
        archive_exists!
        response = MultiZip::Backend::Cli::InfoZip.spawn([
          UNZIP_PROGRAM, UNZIP_PROGRAM_LIST_MEMBERS_SWITCHES, @filename
        ].flatten)

        if response.first
          member_list = response.first.split("\n").sort
          member_list.select!{|m| m =~ /^#{prefix}/} if prefix
          return member_list
        else # error, response.last should contain error message
          raise_info_zip_error!(response.last)
        end
      end

      def read_member(member_path, options={})
        archive_exists!
        member_not_found!(member_path) if member_path =~ /\/$/
        response = MultiZip::Backend::Cli::InfoZip.spawn([
          UNZIP_PROGRAM, UNZIP_PROGRAM_READ_MEMBER_SWITCH, @filename, member_path
        ].flatten)

        return response.first if response.first
          
        raise_info_zip_error!(response.last, :member_path => member_path)
      end

      def write_member(member_path, member_content, options={})
        Dir.mktmpdir do |tempdir|
          member_file = File.new("#{tempdir}/#{member_path}", 'wb')
          member_file.print member_content
          member_file.close

          cwd = Dir.pwd
          Dir.chdir(tempdir)

          response = MultiZip::Backend::Cli::InfoZip.spawn([
            ZIP_PROGRAM, @filename, member_path
          ])
          
          Dir.chdir(cwd)
        end
        true
      end

      def raise_info_zip_error!(message, options={})
        infozip_error = MultiZip::Backend::Cli::InfoZip::ResponseError.new(message)
        case message
        when /End-of-central-directory signature not found/
          raise MultiZip::InvalidArchiveError.new(@filename, infozip_error)
        when /cannot find or open/
          raise MultiZip::ArchiveNotFoundError.new(@filename, infozip_error)
        when /filename not matched/
          raise MultiZip::MemberNotFoundError.new(options[:member_path])
        else
          raise MultiZip::UnknownError.new(@filename, infozip_error)
        end
      end
    end

    
    class ResponseError < MultiZip::InvalidArchiveError
      attr_reader :message
      def initialize(error_message)
        @message = error_message
      end
    end
  end
end
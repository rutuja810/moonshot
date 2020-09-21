class System
  # Executes commands in a subshell.
  #
  # @param command [String] The command to be executed
  # @param env [Hash] Environment variables to set during execution.
  # @param echo [Boolean] Whether or not to echo command output.
  # @param raise_on_failure [Boolean] Whether or not to raise an exception if
  # the command fails.
  # @param log_file [File] Optional file to log the output of the command to.
  # @param working_dir [String] Optional working directory to use.
  #
  # @return [OpenStruct]
  #   success [Boolean] Based on the command cmd exited with status 0.
  #   exitstatus [Integer] Exit code of the command.
  #   output [String] stdout
  #   error [String] stderr
  #
  # @raise RuntimeError if the command exits non-zero
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Style/RescueModifier
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/ParameterLists
  def self.exec(command, env: nil, echo: true, raise_on_failure: true,
                log_file: nil, working_dir: nil)
    collect_stdout = ''
    collect_stderr = ''
    exitstatus = nil
    log_file_present = !log_file.nil?
    params = [command]
    params.push(chdir: working_dir) if working_dir
    params.insert(0, env) if env

    Open3.send(:popen3, *params) do |stdin, stdout, stderr, thread|
      Thread.new do
        Thread.current.report_on_exception = false
        until (c = stdout.getc rescue nil).nil?
          collect_stdout += c

          log_file.write(c) if log_file_present
          next unless echo

          if ["\n", "\r"].include?(c)
            $stdout.puts
          else
            $stdout.write c
          end
        end
      end

      Thread.new do
        Thread.current.report_on_exception = false
        until (c = stderr.read rescue nil).nil?
          collect_stderr += c

          log_file.write(c) if log_file_present
          $stderr.print c if echo
        end
      end

      stdin_thread = Thread.new do
        Thread.current.report_on_exception = false
        loop { stdin.puts $stdin.gets }
      end

      thread.join
      stdin_thread.kill
      exitstatus = thread.value.exitstatus
    end

    unless exitstatus.zero? || raise_on_failure == false
      raise "The command '#{command}' failed with status #{exitstatus}\n"\
            "stdout: #{collect_stdout}\nstderr: #{collect_stderr}"
    end

    OpenStruct.new(
      success: exitstatus.zero?,
      exitstatus: exitstatus,
      output: collect_stdout,
      error: collect_stderr
    )
  end
end

module ToolingInvoker
  class RuncWrapper

    def initialize(job_id, iteration_dir, configuration, execution_timeout: 5)
      @job_id = "hello"#job_id
      @iteration_dir = iteration_dir
      @configuration = configuration
      @execution_timeout = execution_timeout.to_i

      @binary_path = "/opt/container_tools/runc"
      @suppress_output = false
      @memory_limit = 3000000
    end

    def run!
      File.write("#{iteration_dir}/config.json", configuration.to_json)

      actual_command = "#{binary_path} --root root-state run #{job_id}"
      run_cmd = ExternalCommand.new(
        "bash -x -c 'ulimit -v #{memory_limit}; #{actual_command}'",
        timeout: execution_timeout,
        output_limit: 1024*1024
      )


      Dir.chdir(iteration_dir) do
        kill_thread = Thread.new do
          sleep(execution_timeout)
          system("#{binary_path} --root root-state kill #{job_id} KILL")
        end

        begin
          run_cmd.()
        rescue => e
          p "Errored: #{e}"
        end

        kill_thread.kill unless kill_thread.killed?

        p "HERE3"
      end

      p "HERE!!"
      run_cmd
    end

    private
    attr_reader :binary_path, :suppress_output, :memory_limit, :execution_timeout, :iteration_dir, :configuration
    attr_reader :job_id
  end
end


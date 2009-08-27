module Debugger

  # Implements debugger "jump" command
  class JumpCommand < Command
    self.allow_in_control = true

    def numeric?(object)
      true if Float(object) rescue false
    end

    def regexp
      / ^\s*
         (?:jump) \s*
         (?:\s+(\S+))?\s*
         (?:\s+(\S+))?\s*
         $
      /ix
    end

    def execute
      stack_size = Debugger.current_context.stack_size
      if !numeric?(@match[1])
        puts "Bad line number: " + @match[1]
        return false
      end
      line = @match[1].to_i
      file = @match[2]
      file = @state.context.frame_file(file.to_i) if numeric?(file)
      file = @state.context.frame_file(0) if !file
      if Debugger.current_context.jump(line, file)
        @state.line = line if stack_size == Debugger.current_context.stack_size
        CommandProcessor.print_location_and_text(file, line)
      else
        puts "failed; PC unchanged"
      end
    end

    class << self
      def help_command
        %w[jump]
      end

      def help(cmd)
        %{
          jump [line]

          jump to line
         }
     end
    end
  end
end

require 'segment/analytics'

Analytics = Segment::Analytics.new({
                                       write_key: Rails.application.config.segment_io_write_key,
                                       on_error: Proc.new { |status, msg| print msg }
                                   })
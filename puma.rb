require 'puma'
ENV["USING"] = 'web'
ENV['DEV_MODE'] = 'true'
ENV['CMD_MODE'] = 'true'
ENV['EXCL_USER_UUIDS'] = '["__DEV_UUID__"]'


workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['THREAD_COUNT'] || 5)
threads threads_count, threads_count

port        ENV['PORT']     || 4000
environment ENV['RACK_ENV'] || 'development'

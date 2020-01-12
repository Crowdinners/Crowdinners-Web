# A mixin for BaseMessage to be used for reports that are sent to DataDog.
# This module allows you to define the metric names, and it will generate
# the data points and tags, ready to be sent to DataDog API.
module DatadogReport
    extend ActiveSupport::Concern

    module ClassMethods
        # Define the prefix to use for DataDog metrics generated by this class
        def prefix(s = nil)
            @prefix ||= s
        end

        # Define a metric, which is a field that generates data points (so it must be numeric)
        def metric(name)
            metrics << name.to_sym
            field name
        end

        def metrics
            @metrics ||= []
        end
    end

    # Return a map of points to send to DataDog, one point for each metric:
    #       {"metric1" => [timestamp, value], "metric2" => [timestamp, value]}
    def datadog_points
        self.class.metrics.mash do |metric|
            ["#{self.class.prefix}.#{metric}", [timestamp, send(metric)]]
        end
    end

    # Return a list of DataDog tags to attach to generated points
    def datadog_tags
        ["environment:#{Rails.env}"]
    end

    def datadog_options
        { tags: datadog_tags }
    end
end

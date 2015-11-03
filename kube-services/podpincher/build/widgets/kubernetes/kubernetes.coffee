#= require ./zoomable_sunburst.coffee
class Dashing.Kubernetes extends Dashing.Widget

    ready: ->
        node = $(@node)

        @cluster_chart = new ZoomableSunburst(
          node.find('#kubernetes'),
          node.find('#slicename'),
          node.find('#slicehost')
        )

        if @data
            @cluster_chart.drawChart @data

    onData: (data) ->
        console.log("onData: cluster chart: #{@cluster_chart}", @cluster_chart) if @cluster_chart
        @cluster_chart.drawChart data if @cluster_chart



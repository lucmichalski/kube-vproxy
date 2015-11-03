class window.ZoomableSunburst

    constructor: (@container, @name, @host) ->

        @container = $(@container)
        @name = $(@name)
        @host = $(@host)

        @width = @container.outerWidth()
        @height = @container.outerHeight()
        @radius = Math.min(@width, @height) / 2.5;
        @node

        @x = d3.scale.linear().range([
            0
            2 * Math.PI
        ])
        @y = d3.scale.linear().range([
            0
            @radius
        ])

        @svg = d3.select(@container.get(0)).append("svg")
            .attr("width", @width)
            .attr("height", @height)
            .append("g").attr("transform", "translate(" + @width / 2 + "," + (@height / 2 + 10) + ")")

        @partition = d3.layout.partition().value((d) ->
            if d.value
                d.value
            else
                1
        )

        @arc = d3.svg.arc().startAngle((d) =>
            Math.max 0, Math.min(2 * Math.PI, @x(d.x))
        ).endAngle((d) =>
            Math.max 0, Math.min(2 * Math.PI, @x(d.x + d.dx))
        ).innerRadius((d) =>
            Math.max 0, @y(d.y)
        ).outerRadius((d) =>
            Math.max 0, @y(d.y + d.dy)
        )


    format_name: (d) =>
        if d.friendly_name
            "<b>" + d.friendly_name + "</b>"
        else
            "<b>" + d.name + "</b>"

    format_host: (d) =>
        if d.host
            "<b>" + d.host + "</b>"

    arcTween: (d) =>
        xd = d3.interpolate(@x.domain(), [
            d.x
            d.x + d.dx
        ])
        yd = d3.interpolate(@y.domain(), [
            d.y
            1
        ])
        yr = d3.interpolate(@y.range(), [
            (if d.y then 20 else 0)
            @radius
        ])
        (d, i) =>
            (if i then (t) =>
                @arc d
            else (t) =>
                @x.domain xd(t)
                @y.domain(yd(t)).range yr(t)
                @arc d
            )

    click: (d) =>
        @node = d
        @path.transition().duration(750).attrTween "d", @arcTween(d)
        return

    mouseover: (d) =>
        @name.html(@format_name(d))
        @host.html(@format_host(d))

    mouseout: (d) =>
        @name.html("")
        @host.html("")

    findName: (object, name) =>
        return object if object.hasOwnProperty("name") and object["name"] is name
        i = 0

        while i < Object.keys(object).length
            if typeof object[Object.keys(object)[i]] is "object"
                o = @findName(object[Object.keys(object)[i]], name)
                return o if o?
            i++
        null

    update: (data) =>
        if @node
            @node = @findName(data, @node.name)
            if !@node
                @node = data
        else
            @node = data


        @path = @svg.selectAll("path")
            .data(@partition.nodes(data), (d) ->
                d.name + d.host)

        @path.enter()
            .append("path")
            .attr("d", @arc)
#           .attr("stroke", "white")
            .attr("fill", (d) ->
                return d.color )
            .on("click", @click)
            .on("mouseover", @mouseover)
            .on("mouseout", @mouseout)

        @path.exit().remove()

    drawChart: (data) =>
        console.log("drawChart data: #{data}", data)
        @update(data)
        @path.transition().duration(750).attrTween "d", @arcTween(@node)

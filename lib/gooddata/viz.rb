require "gooddata/viz/version"
require 'pp'

module Gooddata
  module Viz
    def self.sha(stuff)
      'a' + Digest::SHA1.hexdigest(stuff)
    end

    def self.to_html(data)
      xm = Builder::XmlMarkup.new(:indent => 0)
      xm.table(border: "0", cellborder: "0", cellpadding: "0") do
        # xm.tr { data[0].keys.each { |key| xm.th(key)}}
        xm.tr do
          # xm.td('')
          xm.td(align: "center", bgcolor: 'black', cellpadding: 5, colspan: 2) do
            xm.font(data.first[:title], color: 'white') 
          end
        end
        data.drop(1).each do |row|
          xm.tr do
            glyph = case row[:type]
            when :attribute
              'a'
            when :fact
              '#'
            when :anchor
              '*'
            else
              "&nbsp;&nbsp;"
            end
            xm.td(align: "left", port: sha(row[:id]), border: "0", cellpadding: "1") do
              xm.b do
                xm << glyph
                xm << '&nbsp;'
              end
              xm.text!("#{row[:title]}")
            end
          end
        end
      end
    end

    def self.data_for_dataset(d, opts = {})
      include_dates = opts[:include_dates]
      data = d.fields.select { |f| [:anchor, :attribute, :fact].include?(f.type)}
                     .reject { |n| n.respond_to?(:anchor?) && n.anchor? && n.labels.empty? }
                     .map {|f| {type: f.type, id: f.id, title: f.title, dataset: d.id} }
      refs = include_dates ? d.references : d.references.reject {|r| r.dataset.is_a?(GoodData::Model::DateDimension)}
      data.concat(refs.map { |f| { type: :reference, title: f.reference, id: "ref_#{f.reference}" } })
      data.unshift({type: :dataset, title: d.title})
      data
    end


    def self.render_blueprint(blueprint, opts = {})
      require 'graphviz'
      require 'builder'
      require 'digest/sha1'

      base_name = opts[:base_name] || 'model'
      engine = opts[:engine] || 'neato'
      # Create a new graph
      include_dates = true

      g = GraphViz.new(:G, type: :digraph, rankdir: 'LR', overlap: 'false', splines: true, :use => engine)
      blueprint.datasets(:all, dd: include_dates).each do |d|
        data = data_for_dataset(d, include_dates: include_dates)
        if d.is_a?(GoodData::Model::DateDimension)
          g.add_nodes(sha(d.id), label: d.id, penwidth: 3, shape: 'box', color: 'black', style: 'filled, rounded', fillcolor: 'lightblue')
        else
          color = d.referenced_by.empty? && !d.referencing.empty? ? 'lemonchiffon1' : 'white'
          g.add_nodes(sha(d.id), penwidth: 1, margin: 0.1, shape: 'box', color: 'black', fillcolor: color, style: 'rounded, filled', label: "<#{to_html(data)}>")
        end

      end

      blueprint.datasets(:all, dd: include_dates).each do |d|
        refs = include_dates ? d.references : d.references.reject {|r| r.dataset.is_a?(GoodData::Model::DateDimension)}
        refs.each do |r|
          puts "[#{d.id}:ref_#{r.reference}, #{r.dataset.id}]"
          begin
            fail "Node #{d.id} could not be found" unless g.find_node(sha(d.id))
            fail "Node #{r.dataset.id} could not be found" unless g.find_node(sha(r.dataset.id))
            fail "REF #{"ref_#{r.reference}"} could not be found" unless g.find_node(sha(d.id))[:label].to_s[sha("ref_#{r.reference}")]
          end
          if opts[:links_from_references]
            g.add_edges(sha(r.dataset.id), { sha(d.id) => sha("ref_#{r.reference}") }, dir: 'back')
          else
            g.add_edges(sha(r.dataset.id), sha(d.id), dir: 'back')
          end
        end
      end

      g.output(svg: "#{base_name}.svg")
      g.output(png: "#{base_name}.png")
      g.output(dot: "#{base_name}.dot")
    end
  end
end



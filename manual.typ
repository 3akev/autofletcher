#import "@preview/tidy:0.2.0"
#import "@preview/fletcher:0.4.3" as fletcher: diagram, node, edge, shapes
#import "autofletcher.typ": placer, place_nodes, edges, tree_placer, vecadd, vecmult

#let scope = (
  diagram: diagram,
  node: node,
  edge: edge,
  placer: placer,
  place_nodes: place_nodes,
  edges: edges,
  tree_placer: tree_placer,
  shapes: shapes,
  vecadd: vecadd
)

#let example(code) = {
  {
    set text(7pt)
    box(code)
  }
  {eval(code.text, mode: "markup", scope: scope)}
}

#align(center)[#text(2.0em, `autofletcher`)]
#v(1cm)

This module provides functions to (sort of) abstract away manual placement of
coordinates.

Here's a few examples.

=== Flowchart

#example(```typst
#diagram(
  spacing: (0.2cm, 1.5cm),
  node-stroke: 1pt,
  {
    let r = (0, 0)
    let flowchart_placer = placer((0, 1), (1, 0))

    node(r, [start], shape: shapes.circle)
    // question is a node function with the position pre-applied
    let ((iquestion, ), (question, )) = place_nodes(r, 1, flowchart_placer, spread: 20)

    question([Is this true?], shape: shapes.diamond)
    edge(r, iquestion, "-|>")

    let ((iend, ino), (end, no)) = place_nodes(iquestion, 2, flowchart_placer, spread: 10)

    end([End], shape: shapes.circle)
    no([OK, is this true?], shape: shapes.diamond)

    edge(iquestion, iend, "-|>", label: [yes])
    edge(iquestion, ino, "-|>", label: [no])

    edge(ino, iend, "-|>", label: [yes], corner: right)

    edge(ino, r, "-|>", label: [no], corner: left)

  })
```)

=== Tree diagram

#example(```typst
#diagram(
spacing: (0.0cm, 0.5cm),
{
  let r = (0, 0)
  node(r, [13])

  let (idxs0, (c1, c2, c3)) = place_nodes(r, 3, tree_placer, spread: 10)

  c1([10])
  c2([11])
  c3([12])

  edges(r, idxs0, "->")

  for (i, parent) in idxs0.enumerate() {
    let (idxs, (c1, c2, c3)) = place_nodes(parent, 3, tree_placer, spread: 2)

    c1([#(i * 3 + 1)])
    c2([#(i * 3 + 2)])
    c3([#(i * 3 + 3)])

    edges(parent, idxs, "->")
  }
})
```)

=== Custom placers

If the built-in placers don't fit your needs, you can create a custom placer;
that is, a function that calculates the relative positions for each child.
It should accept, in order:
+ (`int`) the index of the child
+ (`int`) the total number of children
+ (`int`) the spread
and it should return a pair of coordinates, `(x, y)`.
```typst
#let custom_placer(i, num_total, spread) = {
  // custom logic here
  return (0, 1)
}

#diagram({
  let r = (0, 0)
  node(r, [root])

  let ((ic1, ic2), (c1, c2)) = place_nodes(r, 2, custom_placer)
})
```

#pagebreak(weak: true)
== API reference

#let docs = tidy.parse-module(read("autofletcher.typ"))
#tidy.show-module(docs, style: tidy.styles.default)


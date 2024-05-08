#import "@preview/fletcher:0.4.3" as fletcher: diagram, node, edge

// math helpers
#let vecadd(v1, v2) = v1.zip(v2).map(x => x.sum())

#let vecmult(v1, v2) = v1.zip(v2).map(x => x.product())

#let vecmultx(v, s) = (v.at(0) * s, v.at(1))

/// Calculates the relative position of a child node, like in a tree
///
/// Don't call this directly; instead, pass this as a parameter to `place_nodes`.
#let tree_placer(i, num_total, spread) = {
  let idx = i - int((num_total - 1)/2)
  let rel_vec = (int(idx * spread), 1)
  return rel_vec
}

/// Returns a generic placer, where children are placed according to the given
/// relative positions. If more children are present than there are positions, positions
/// are repeated.
///
/// This is probably sufficient for most use cases.
///
/// - ..placements (coordinates): 
/// -> function
#let placer(..placements) = {
  let tab = placements.pos()

  let discrete_placer(i, num_total, spread) = {
    let pos = tab.at(calc.rem(i, tab.len()))
    return vecmultx(pos, spread)
  }

  return discrete_placer
}

/// Calculates the positions of `num_children` children of `parent` node.
///
/// Returns a pair of arrays. The first array contains the coordinates of the
/// children, and the second array contains the nodes partially applied with
/// the calculated positions.
///
/// - parent (coordinates): The coordinates of the parent node
/// - num_children (int): The number of children to place
/// - placer (function): The function to calculate the relative positions of the children
/// - spread (int): A multiplier for the x coordinate, "spreads" 
///               children out. Increase this for high parent nodes.
/// -> (array of coordinates + array of nodes)
#let place_nodes(parent, num_children, placer, spread: 1) =  {
  let coords = ()
  let children = ()
    for i in range(0, num_children) {
      let rel_vec = placer(i, num_children, spread)
      let pos = vecadd(parent, rel_vec)
      coords = coords + (pos, )
      children = children + (node.with(pos),)
    }
  return (coords, children)
}

/// Convenience function that draws edges between a parent node and its
/// children, given the coordinates of the parent and children.
///
/// - parent (coordinates): The coordinates of the parent node
/// - children (array of coordinates): The coordinates of the children nodes
/// - ..options (any): Additional options to pass to `edge`
///
#let edges(parent, children, ..options) = {
  for child in children {
    edge(parent, child, ..options.pos(), ..options.named())
  }
}


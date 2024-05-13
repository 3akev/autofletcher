#import "@preview/fletcher:0.4.3" as fletcher: diagram, node, edge


// math helpers
#let vecadd(v1, v2) = v1.zip(v2).map(x => x.sum())

#let vecmult(v1, v2) = v1.zip(v2).map(x => x.product())

#let vecmultx(v, s) = (v.at(0) * s, v.at(1))

/// Calculates the relative position of a child node, like in a tree
///
/// Don't call this directly; instead, pass this as a parameter to `place_nodes`.
///
/// - i (int): The index of the child node
/// - num_total (int): The total number of children
#let tree_placer(i, num_total) = {
  let idx = i - int((num_total - 1)/2)
  return (idx, 1)
}

/// Returns a placer that places children in a circular arc
///
/// It appears this breaks spread, probably because it uses 
/// fractional coordinates. Also, don't mix it with other non-fractional 
/// placers. It messes up the graph
///
/// - start (angle, float): The starting angle of the arc
/// - length (angle, float): The length of the arc
/// - radius (float): The radius of the circle
#let arc_placer(start, length: 2*calc.pi, radius: 1) = {
  if type(start) == angle {
    start = start.rad()
  }
  if type(length) == angle {
    length = length.rad()
  }

  let length = calc.clamp(length, 0, 2 * calc.pi)

  let r = (radius, radius)

  let circular_placer(i, num_total) = {
    // if it's not a full circle, we subtract one from the total number of
    // children cuz i is 0-indexed, but num_total is 1-indexed (sort of), so
    // that leaves the last "slot" unused. this is useful when it's a full
    // circle, but not when it's an arc
    if length != 2*calc.pi and num_total > 1 {
      num_total = num_total - 1
    }
    let angle = start + length * i / num_total
    let vec = (calc.cos(angle), calc.sin(angle))
    return vecmult(r, vec)
  }

  return circular_placer
}

/// A pre-defined arc placer that places children in a full circle.
#let circle_placer = arc_placer(0, length: 2 * calc.pi)

/// Returns a generic placer, where children are placed according to the given
/// relative positions. If more children are present than there are positions, positions
/// are repeated.
///
/// This is probably sufficient for most use cases.
///
/// - ..placements (coordinates): Relative positions to assign to children
/// -> function
#let placer(..placements) = {
  let tab = placements.pos()

  let discrete_placer(i, num_total) = {
    return tab.at(calc.rem(i, tab.len()))
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
      let rel_vec = placer(i, num_children)
      let rel_vec = vecmultx(rel_vec, spread)
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


import gleam/io
import types


pub fn main() -> Nil {
  let piece = types.PieceArchetype(4.0, 7.0, 85.0, 4.0 /. 7.0, False)
  io.println("Salut")
}

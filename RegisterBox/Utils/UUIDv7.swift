import Foundation

/// Genera un UUID versión 7 — ordenable por tiempo, compatible con PostgreSQL.
/// El UUID v7 embebe un timestamp de 48 bits en los primeros 6 bytes,
/// lo que garantiza inserción secuencial en índices B-tree.
func makeUUIDv7() -> UUID {
    var bytes = [UInt8](repeating: 0, count: 16)

    // 48 bits de timestamp en milisegundos (bytes 0-5)
    let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
    bytes[0] = UInt8((timestamp >> 40) & 0xFF)
    bytes[1] = UInt8((timestamp >> 32) & 0xFF)
    bytes[2] = UInt8((timestamp >> 24) & 0xFF)
    bytes[3] = UInt8((timestamp >> 16) & 0xFF)
    bytes[4] = UInt8((timestamp >> 8) & 0xFF)
    bytes[5] = UInt8(timestamp & 0xFF)

    // Versión 7 (4 bits) + random (12 bits) en bytes 6-7
    bytes[6] = 0x70 | (UInt8.random(in: 0x00...0x0F))
    bytes[7] = 0x80 | (UInt8.random(in: 0x00...0x3F))

    // 8 bytes random (bytes 8-15)
    for i in 8..<16 {
        bytes[i] = UInt8.random(in: 0x00...0xFF)
    }

    return UUID(uuid: (
        bytes[0],  bytes[1],  bytes[2],  bytes[3],
        bytes[4],  bytes[5],  bytes[6],  bytes[7],
        bytes[8],  bytes[9],  bytes[10], bytes[11],
        bytes[12], bytes[13], bytes[14], bytes[15]
    ))
}

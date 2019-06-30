enum IpAddrKind {
    V4,
    V6,
}

struct IpAddr {
    kind: IpAddrKind,
    address: String,
}

// ----------------------
// The data above could be expressed as the following
// by associating a String with the enum.

enum IpAddrV2 {
    V4(String),
    V6(String),
}

fn main() {
    let home = IpAddr {
        kind: IpAddrKind::V4,
        address: String::from("127.0.0.1"),
    };

    let loopback = IpAddr {
        kind: IpAddrKind::V6,
        address: String::from("::1"),
    };

    let homeV2 = IpAddrV2::V4(String::from("127.0.0.1"));
    let loopbackV2 = IpAddrV2::V6(String::from("::1"));
}

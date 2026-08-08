# Networking: VLAN Design Lab

Two Cisco Packet Tracer labs built for MIS6040 (Networks and Wireless Communications),
covering VLAN segmentation and inter-VLAN routing.

## Files

- **`router-on-a-stick-topology.pkt`** — A single router with a trunked sub-interface
  configuration routing traffic between multiple VLANs through one physical link.
- **`vlan-two-switch-lab.pkt`** — A two-switch topology demonstrating VLAN trunking and
  propagation across switches, with devices assigned to VLANs by port.

## What's demonstrated

- VLAN creation and port assignment
- 802.1Q trunking between switches
- Router sub-interface configuration for inter-VLAN routing (router-on-a-stick)
- Basic connectivity verification across VLANs

## How to open

Requires [Cisco Packet Tracer](https://www.netacad.com/courses/packet-tracer) (free with a
Cisco Networking Academy account). Open the `.pkt` file directly — the saved topology,
device configs, and cabling will load as-is.

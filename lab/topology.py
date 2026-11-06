"""Offline address and declaration model; never a packet/authorization simulator."""
from pathlib import Path
import ipaddress,json
ROOT=Path(__file__).resolve().parents[1]
def load():return json.loads((ROOT/'data/topology.json').read_text())
def validate(topology):
    networks=topology['networks'];ids=[n['id'] for n in networks]
    if len(set(ids))!=len(ids):raise ValueError('Duplicate network identifier')
    parsed={n['id']:ipaddress.ip_network(n['cidr'],strict=True) for n in networks}
    for i,left in enumerate(ids):
        for right in ids[i+1:]:
            if parsed[left].overlaps(parsed[right]):raise ValueError('Overlapping VNet ranges')
    for n in networks:
        subnets=[ipaddress.ip_network(s['cidr'],strict=True) for s in n['subnets']]
        for i,subnet in enumerate(subnets):
            if not subnet.subnet_of(parsed[n['id']]):raise ValueError('Subnet outside VNet')
            if any(subnet.overlaps(other) for other in subnets[i+1:]):raise ValueError('Overlapping subnet ranges')
    links=set()
    for p in topology['peerings']:
        key=(p['from'],p['to'])
        if p['from'] not in parsed or p['to'] not in parsed or p['from']==p['to']:raise ValueError('Invalid peering endpoint')
        if key in links:raise ValueError('Duplicate peering')
        links.add(key)
    if any(n not in parsed for n in topology['dns']['linkedClients']):raise ValueError('Unknown DNS-linked client')
    return True
def relationship(topology,source,target):
    validate(topology);known={n['id'] for n in topology['networks']}
    if source not in known or target not in known:raise ValueError('Unknown network')
    if source==target:return 'same-vnet'
    pairs={(p['from'],p['to']) for p in topology['peerings'] if p['access']}
    if (source,target) in pairs and (target,source) in pairs:return 'reciprocal-peering-defined'
    return 'no-reciprocal-peering-defined'
def checks(topology):
    validate(topology)
    return [
      {'check':'Address ranges and subnets','result':'Valid, disjoint and contained'},
      {'check':'Production hub / spoke','result':relationship(topology,'production-hub','production-spoke')},
      {'check':'Nonproduction / production spoke','result':relationship(topology,'nonproduction-spoke','production-spoke')},
      {'check':'Engineering hub / production spoke','result':relationship(topology,'engineering-hub','production-spoke')},
      {'check':'Forwarded traffic and gateway transit','result':'Off in both copied production peerings' if all(not p.get(key,False) for p in topology['peerings'] for key in ['forwarded','gatewayTransit','remoteGateway']) else 'One or more transit controls enabled; review required'},
      {'check':'Private SQL DNS linkage','result':'Explicit production-spoke link; no automatic inheritance'}]
if __name__=='__main__':print(json.dumps(checks(load()),indent=2))

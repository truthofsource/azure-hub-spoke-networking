import copy,unittest,re
from pathlib import Path
from lab.topology import load,validate,relationship,checks,ROOT
class TopologyTests(unittest.TestCase):
    def setUp(self):self.t=load()
    def test_current_ranges_are_valid(self):self.assertTrue(validate(self.t))
    def test_overlapping_vnets_are_rejected(self):
        self.t['networks'][1]['cidr']='10.30.0.0/16'
        with self.assertRaisesRegex(ValueError,'Overlapping VNet'):validate(self.t)
    def test_escaped_subnet_is_rejected(self):
        self.t['networks'][0]['subnets'][0]['cidr']='10.90.0.0/26'
        with self.assertRaisesRegex(ValueError,'outside'):validate(self.t)
    def test_subnet_overlap_is_rejected(self):
        self.t['networks'][0]['subnets'][1]['cidr']='10.30.0.16/28'
        with self.assertRaisesRegex(ValueError,'Overlapping subnet'):validate(self.t)
    def test_production_pair_is_reciprocal(self):self.assertEqual(relationship(self.t,'production-hub','production-spoke'),'reciprocal-peering-defined')
    def test_one_direction_does_not_prove_pair(self):
        self.t['peerings'].pop();self.assertEqual(relationship(self.t,'production-hub','production-spoke'),'no-reciprocal-peering-defined')
    def test_second_spoke_is_not_transitively_connected(self):
        self.t['peerings'] += [{'from':'production-hub','to':'nonproduction-spoke','access':True},{'from':'nonproduction-spoke','to':'production-hub','access':True}]
        self.assertEqual(relationship(self.t,'production-spoke','nonproduction-spoke'),'no-reciprocal-peering-defined')
    def test_engineering_vnet_is_separate(self):self.assertEqual(relationship(self.t,'engineering-hub','production-spoke'),'no-reciprocal-peering-defined')
    def test_dns_is_not_inherited_by_peering(self):self.assertNotIn('production-hub',self.t['dns']['linkedClients'])
    def test_source_peerings_have_no_transit(self):
        source=(ROOT/'infra/modules/foundation/hub.tf').read_text()
        for field in ['allow_forwarded_traffic','allow_gateway_transit','use_remote_gateways']:
            self.assertEqual(len(re.findall(field+r'\s*=\s*false',source)),2)
    def test_snapshot_network_prefixes_match_selected_source(self):
        text=''.join((ROOT/p).read_text() for p in ['infra/modules/foundation/network.tf','infra/modules/foundation/hub.tf','reference/nonproduction/network.tf','reference/shared-services/network.tf'])
        for network in self.t['networks']:
            self.assertIn(network['cidr'],text)
            for subnet in network['subnets']:self.assertIn(subnet['cidr'],text)
    def test_duplicate_peering_is_rejected(self):
        self.t['peerings'].append(copy.deepcopy(self.t['peerings'][0]))
        with self.assertRaisesRegex(ValueError,'Duplicate peering'):validate(self.t)
    def test_unknown_network_rejected(self):
        with self.assertRaisesRegex(ValueError,'Unknown network'):relationship(self.t,'unknown','production-hub')
    def test_six_reference_checks(self):self.assertEqual(len(checks(self.t)),6)

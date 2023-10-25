import 'package:template/api/api_party_view/api_party_view.dart';
import 'package:flutter/material.dart';
import 'package:template/provider/provider_infoview.dart';
import '.././api/api_get_title_from_xml.dart';

import '../models/model_partyview_ledamot.dart';
import '../models/model_partyview_ledamotresult.dart';

class ProviderPartyView extends ChangeNotifier {
  List<Ledamot> _ledamotList = [];

  List<double> _PieChartValues = [0, 0, 0, 0];
  List<LedamotResult> _ledamotResultList = [];
  List<LedamotResult> _originalLedamotResultList = [];
  List<Ledamot> _partiLedareList = [];
  List<Ledamot> get partiLedareList => _partiLedareList;

  String _selectedParty = 'S';

  String get selectedParty => _selectedParty;
  List get PieChartValues => _PieChartValues;

  Future<void> fetchPartyMemberVotes(selectedParty, beteckning, punkt) async {
    var ledamotResultList =
        await fetchLedamotListVotes(selectedParty, beteckning, punkt);

    // Preserve the original unfiltered list sorted by name
    _originalLedamotResultList = sortLedamotResultList(ledamotResultList);

    // Set the filtered list initially to the original list
    _ledamotResultList = _originalLedamotResultList;
    notifyListeners();
  }

  List<LedamotResult> sortLedamotResultList(
      List<LedamotResult> ledamotResultList) {
    // sort on last name
    ledamotResultList.sort((a, b) => a.namn.compareTo(b.namn));
    return ledamotResultList;
  }

  ProviderInfoView providerInfoView = ProviderInfoView();
  List<LedamotResult> get ledamotResultList => _ledamotResultList;
  //  .where((result) => result.punkt == providerInfoView.punkt)
  //  .toList();

  Ledamot findLedamotByIntressentId(String intressentId) {
    // returns instance of ledamot matched on iid
    // used to get image for each leadmot in ledamotresultlist
    return ledamotList.firstWhere(
      (ledamot) => ledamot.intressentId == intressentId,
      orElse: () => Ledamot(
          tilltalsnamn: '',
          efternamn: '',
          bildUrl80: // placeholder
              'https://www.pngjoy.com/pngm/52/1165788_female-blank-facebook-profile-picture-female-transparent-png.png',
          party: '',
          intressentId: ''),
    );
  }

  void setSelectedParty(String selectedParty) {
    // sets selected party for party_view. updates from selection in info_view.
    _selectedParty = selectedParty;
    notifyListeners();
  }

  void setPieChartValues(yes, no, pass, abscent) {
    _PieChartValues[0] = double.parse(yes);
    _PieChartValues[1] = double.parse(no);
    _PieChartValues[2] = double.parse(pass);
    _PieChartValues[3] = double.parse(abscent);
  }

  Future<void> fetchPartyMembers(selectedParty) async {
    var ledamotList = await fetchLedamotList(selectedParty);
    _partiLedare = ledamotList.firstWhere((ledamot) => ledamot.partiLedare);
    _partiLedareList =
        ledamotList.where((ledamot) => ledamot.partiLedare).toList();
    _ledamotList = ledamotList;
    notifyListeners();
  }

  List<Ledamot> get ledamotList => _ledamotList; // Returns sorted list

  void searchLedamot(String searchTerm) {
    // filters Listview of party members
    searchTerm = searchTerm.toLowerCase();
    _ledamotResultList = _originalLedamotResultList
        .where((ledamot) => ledamot.namn.toLowerCase().contains(searchTerm))
        .toList();
    notifyListeners();
  }

  Future<void> setPunktTitle(beteckning, punkt) async {
    // Setter for notion point title
    String url = 'https://data.riksdagen.se/utskottsforslag/HA01${beteckning}';
    var data = await fetchTitle(url, punkt);

    _punktTitle =
        data?['rubrik'] ?? ''; // Provide a default value if 'rubrik' is null

    notifyListeners();
  }

  Ledamot? _partiLedare;
  Ledamot? get partiLedare => _partiLedare;

  String _punktTitle = '';
  String get punktTitle => _punktTitle;
}
import '../../../core/constants/image_url.dart';

class NavBarItems {
  final String title;
  final String icon;
  final int index;

  NavBarItems({required this.title, required this.icon, required this.index});
}

List<NavBarItems> navBarItems = <NavBarItems>[
  NavBarItems(title: "Home", icon: TImageUrl.home, index: 0),
  NavBarItems(title: "QR Scan", icon: TImageUrl.qrCode, index: 1),
  NavBarItems(title: "Transactions", icon: TImageUrl.transaction, index: 2),
  NavBarItems(title: "More", icon: TImageUrl.menu, index: 3),
];

// to generate it in a row use the following widget

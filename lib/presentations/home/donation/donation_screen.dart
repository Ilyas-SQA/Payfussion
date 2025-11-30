import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:payfussion/core/constants/fonts.dart';
import 'package:payfussion/core/theme/theme.dart';
import 'package:payfussion/presentations/home/donation/donation_form_screen.dart';


class Foundation {
  final String name;
  final String category;
  final String description;
  final String website;
  final String icon;
  final String revenue;

  Foundation({
    required this.name,
    required this.category,
    required this.description,
    required this.website,
    required this.icon,
    required this.revenue,
  });
}

class DonateListScreen extends StatefulWidget {
  const DonateListScreen({Key? key}) : super(key: key);

  @override
  State<DonateListScreen> createState() => _DonateListScreenState();
}

class _DonateListScreenState extends State<DonateListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<Foundation> foundations = [
    // Major Foundations
    Foundation(
      name: 'Bill & Melinda Gates Foundation',
      category: 'Healthcare & Development',
      description: 'Global health, poverty reduction, and education initiatives worldwide',
      website: 'gatesfoundation.org',
      icon: "assets/images/home/donation/bill_melinda.png",
      revenue: '\$34.6B+ assets',
    ),
    Foundation(
      name: 'Feeding America',
      category: 'Hunger Relief',
      description: 'Network of 200 food banks serving 1 in 7 Americans nationwide',
      website: 'feedingamerica.org',
      icon: "assets/images/home/donation/feeding_america.png",
      revenue: '\$4.2B revenue',
    ),
    Foundation(
      name: 'United Way Worldwide',
      category: 'Community Support',
      description: 'Network of 1,800 local nonprofits promoting community development',
      website: 'unitedway.org',
      icon: "assets/images/home/donation/united_way.png",
      revenue: '\$3.8B revenue',
    ),
    Foundation(
      name: 'Goodwill Industries',
      category: 'Employment & Training',
      description: 'Job training and employment services through donated goods sales',
      website: 'goodwill.org',
      icon: "assets/images/home/donation/goodwill_Industries.png",
      revenue: '\$7.4B revenue',
    ),
    Foundation(
      name: 'Direct Relief',
      category: 'Medical Aid',
      description: 'Largest charitable medicine program serving 30M+ Americans',
      website: 'directrelief.org',
      icon: "assets/images/home/donation/direct_relief.jpeg",
      revenue: '\$2.2B revenue',
    ),
    Foundation(
      name: 'American Red Cross',
      category: 'Disaster Relief',
      description: 'Emergency assistance, disaster relief, and blood donation services',
      website: 'redcross.org',
      icon: "assets/images/home/donation/american_red_cross.jpeg",
      revenue: 'Major nonprofit',
    ),
    Foundation(
      name: 'St. Jude Children\'s Research Hospital',
      category: 'Healthcare',
      description: 'Leading children\'s hospital treating pediatric catastrophic diseases',
      website: 'stjude.org',
      icon: "assets/images/home/donation/st_jude.png",
      revenue: 'Major healthcare',
    ),
    Foundation(
      name: 'The Salvation Army',
      category: 'Social Services',
      description: 'Providing assistance to those in need without discrimination',
      website: 'salvationarmyusa.org',
      icon: "assets/images/home/donation/salvation.png",
      revenue: 'National nonprofit',
    ),
    Foundation(
      name: 'YMCA of the USA',
      category: 'Community Health',
      description: 'Youth development, healthy living, and social responsibility programs',
      website: 'ymca.org',
      icon: "assets/images/home/donation/ymca.jpeg",
      revenue: '10,000+ locations',
    ),
    Foundation(
      name: 'Habitat for Humanity',
      category: 'Housing',
      description: 'Building and improving homes for families in need',
      website: 'habitat.org',
      icon: "assets/images/home/donation/habitat.png",
      revenue: 'Housing nonprofit',
    ),
    Foundation(
      name: 'American Cancer Society',
      category: 'Healthcare',
      description: 'Cancer research, education, and patient support services',
      website: 'cancer.org',
      icon: "assets/images/home/donation/cancer_society.png",
      revenue: 'Medical research',
    ),
    Foundation(
      name: 'Planned Parenthood',
      category: 'Healthcare',
      description: 'Reproductive healthcare services at 600+ health centers',
      website: 'plannedparenthood.org',
      icon: "assets/images/home/donation/planned.png",
      revenue: '2.1M+ patients',
    ),

    Foundation(
      name: 'World Wildlife Fund',
      category: 'Environment',
      description: 'Conservation organization protecting endangered species',
      website: 'worldwildlife.org',
      icon: "assets/images/home/donation/world_wildlife.png",
      revenue: 'Conservation',
    ),
    Foundation(
      name: 'Boys & Girls Clubs of America',
      category: 'Youth Development',
      description: 'Youth development programs enabling young people to reach potential',
      website: 'bgca.org',
      icon: "assets/images/home/donation/boy_girl_club.jpeg",
      revenue: 'Youth services',
    ),
    Foundation(
      name: 'Good360',
      category: 'Product Donation',
      description: 'Distributed \$2.5B+ in needed goods to 100,000+ nonprofit members',
      website: 'good360.org',
      icon: "assets/images/home/donation/good_360.jpeg",
      revenue: '\$1.69B revenue',
    ),
    Foundation(
      name: 'Doctors Without Borders',
      category: 'Medical Aid',
      description: 'International medical humanitarian organization',
      website: 'doctorswithoutborders.org',
      icon: "assets/images/home/donation/doctor_border.jpeg",
      revenue: 'International aid',
    ),
    Foundation(
      name: 'American Heart Association',
      category: 'Healthcare',
      description: 'Fighting heart disease and stroke through research and education',
      website: 'heart.org',
      icon: "assets/images/home/donation/heart_association.png",
      revenue: 'Health nonprofit',
    ),
    Foundation(
      name: 'Lutheran Services in America',
      category: 'Social Services',
      description: 'Network of 300 Lutheran nonprofits serving 6M+ people annually',
      website: 'lutheranservices.org',
      icon: "assets/images/home/donation/lutheran.png",
      revenue: '6M+ served',
    ),
    Foundation(
      name: 'MAP International',
      category: 'Medical Aid',
      description: 'Providing life-changing medicines to people in need worldwide',
      website: 'map.org',
      icon: "assets/images/home/donation/map.png",
      revenue: 'Medical supplies',
    ),
    Foundation(
      name: 'Ford Foundation',
      category: 'Social Justice',
      description: 'Supporting justice, creativity, and democratic values worldwide',
      website: 'fordfoundation.org',
      icon: "assets/images/home/donation/ford.jpeg",
      revenue: 'Major foundation',
    ),
    Foundation(
      name: 'Rockefeller Foundation',
      category: 'Development',
      description: 'Advancing health, food security, and clean energy initiatives',
      website: 'rockefellerfoundation.org',
      icon: "assets/images/home/donation/rocke_feller.png",
      revenue: '\$6.3B assets',
    ),
    Foundation(
      name: 'William & Flora Hewlett Foundation',
      category: 'Education & Arts',
      description: 'Supporting education, environment, and performing arts globally',
      website: 'hewlett.org',
      icon: "assets/images/home/donation/william.jpeg",
      revenue: '\$12.5B assets',
    ),
    Foundation(
      name: 'Robert Wood Johnson Foundation',
      category: 'Healthcare',
      description: 'Improving health and wellbeing of American citizens',
      website: 'rwjf.org',
      icon: "assets/images/home/donation/rwjf.jpeg",
      revenue: '\$500M+ grants',
    ),
    Foundation(
      name: 'Lilly Endowment',
      category: 'Education & Religion',
      description: 'Supporting educational, religious, and charitable purposes',
      website: 'lillyendowment.org',
      icon: "assets/images/home/donation/lilly.png",
      revenue: 'Major endowment',
    ),
    Foundation(
      name: 'Gordon & Betty Moore Foundation',
      category: 'Science & Environment',
      description: 'Environmental conservation, scientific research, and patient care',
      website: 'moore.org',
      icon: "assets/images/home/donation/gordon.jpeg",
      revenue: '\$8.3B assets',
    ),
    Foundation(
      name: 'David & Lucile Packard Foundation',
      category: 'Environment & Children',
      description: 'Improving lives of children and protecting the planet',
      website: 'packard.org',
      icon: "assets/images/home/donation/david.png",
      revenue: 'Major foundation',
    ),
    Foundation(
      name: 'W.K. Kellogg Foundation',
      category: 'Children & Families',
      description: 'Supporting vulnerable children and their families',
      website: 'wkkf.org',
      icon: "assets/images/home/donation/wk.jpeg",
      revenue: 'Family support',
    ),
    Foundation(
      name: 'Andrew W. Mellon Foundation',
      category: 'Arts & Humanities',
      description: 'Supporting arts, humanities, and higher education',
      website: 'mellon.org',
      icon: "assets/images/home/donation/andrew.png",
      revenue: 'Arts support',
    ),
    Foundation(
      name: 'Conrad N. Hilton Foundation',
      category: 'Humanitarian',
      description: 'Improving lives of disadvantaged people worldwide',
      website: 'hiltonfoundation.org',
      icon: "assets/images/home/donation/conrad.jpeg",
      revenue: '\$6.3B assets',
    ),
    Foundation(
      name: 'Susan G. Komen',
      category: 'Healthcare',
      description: 'Leading breast cancer organization fighting for cure',
      website: 'komen.org',
      icon: "assets/images/home/donation/susan.png",
      revenue: 'Breast cancer',
    ),
    Foundation(
      name: 'Human Rights Watch',
      category: 'Human Rights',
      description: 'Independent organization upholding human dignity and rights',
      website: 'hrw.org',
      icon: "assets/images/home/donation/human_right.png",
      revenue: 'Rights advocacy',
    ),
    Foundation(
      name: 'Human Rights Campaign',
      category: 'LGBTQ+ Rights',
      description: 'Advocating for LGBTQ+ equality through lobbying and education',
      website: 'hrc.org',
      icon: "assets/images/home/donation/human_right_campaign.png",
      revenue: 'Advocacy',
    ),
    Foundation(
      name: 'NAMI (National Alliance on Mental Illness)',
      category: 'Mental Health',
      description: 'Improving lives of individuals affected by mental illness',
      website: 'nami.org',
      icon: "assets/images/home/donation/nami.jpeg",
      revenue: 'Mental health',
    ),
    Foundation(
      name: 'Wounded Warrior Project',
      category: 'Veterans',
      description: 'Supporting veterans with physical or mental injuries',
      website: 'woundedwarriorproject.org',
      icon: "assets/images/home/donation/wounded.jpeg",
      revenue: 'Veterans support',
    ),
    Foundation(
      name: 'Billy Graham Evangelistic Association',
      category: 'Religious',
      description: 'Spreading Christian message through evangelism and outreach',
      website: 'billygraham.org',
      icon: "assets/images/home/donation/billy_graham.png",
      revenue: 'Christian ministry',
    ),
    Foundation(
      name: 'American Kennel Club',
      category: 'Animal Welfare',
      description: 'Promoting responsible dog ownership and canine health',
      website: 'akc.org',
      icon: "assets/images/home/donation/amc.jpeg",
      revenue: 'Dog welfare',
    ),
    Foundation(
      name: 'Big Cat Rescue',
      category: 'Animal Welfare',
      description: 'Rescuing and providing sanctuary for abused big cats',
      website: 'bigcatrescue.org',
      icon: "assets/images/home/donation/big_cat.jpeg",
      revenue: 'Animal rescue',
    ),
    Foundation(
      name: 'Pew Charitable Trusts',
      category: 'Policy Research',
      description: 'Data-driven solutions to pressing public policy challenges',
      website: 'pewtrusts.org',
      icon: "assets/images/home/donation/pew.png",
      revenue: '\$7.2B assets',
    ),
    Foundation(
      name: 'J. Paul Getty Trust',
      category: 'Arts',
      description: 'Understanding and preserving visual arts worldwide',
      website: 'getty.edu',
      icon: "assets/images/home/donation/getty.jpeg",
      revenue: '\$12.5B assets',
    ),
    Foundation(
      name: 'Walton Family Foundation',
      category: 'Education & Environment',
      description: 'Improving K-12 education and protecting rivers and oceans',
      website: 'waltonfamilyfoundation.org',
      icon: "assets/images/home/donation/walton.jpeg",
      revenue: '\$5.7B assets',
    ),
  ];

  List<String> get categories {
    Set<String> cats = {'All'};
    for (var f in foundations) {
      cats.add(f.category);
    }
    return cats.toList()..sort();
  }

  List<Foundation> get filteredFoundations {
    final String query = _searchQuery.trim().toLowerCase();
    final String selectedCategory = _selectedCategory;

    return foundations.where((Foundation foundation) {
      final String name = foundation.name.toLowerCase();
      final String category = foundation.category.toLowerCase();
      final String description = foundation.description.toLowerCase();
      final String website = foundation.website.toLowerCase();

      final bool matchesSearch =
          query.isEmpty ||
              name.contains(query) ||
              category.contains(query) ||
              description.contains(query) ||
              website.contains(query);

      final bool matchesCategory =
          selectedCategory == 'All' ||
              foundation.category.toLowerCase() == selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search foundations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty ?
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                ) : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: MyTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredFoundations.length} foundations found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Total: ${foundations.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Foundation List
          Expanded(
            child: filteredFoundations.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No foundations found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _selectedCategory = 'All';
                      });
                    },
                    child: const Text('Clear filters'),
                  ),
                ],
              ),
            ) :
            ListView.builder(
              itemCount: filteredFoundations.length,
              itemBuilder: (BuildContext context, int index) {
                final Foundation foundation = filteredFoundations[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(5.r),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DonationFormScreen(
                          foundationName: foundation.name,
                          category: foundation.category,
                          description: foundation.description,
                          website: foundation.website,
                        )));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.asset(foundation.icon,height: 50,width: 50,),
                            ),
                            const SizedBox(width: 16),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    foundation.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          foundation.category,
                                          style: Font.montserratFont(
                                            fontSize: 11,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    foundation.description,
                                    style: Font.montserratFont(
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Arrow
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
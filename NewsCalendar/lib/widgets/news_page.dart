import 'package:flutter/material.dart';
import '../widgets/news.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);
  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16),
      children: [
        NewsCard(
          id: 'news_1',
          imageUrl:
              'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=1200&q=80',
          title: 'New Drought-Resistant Crop Varieties Released for Indian Farmers',
          description:
              'Scientists have developed new drought-resistant crop varieties that can thrive in water-scarce conditions. These varieties are specifically designed for Indian agricultural conditions.',
          fullContent:
              'Agricultural scientists at the Indian Council of Agricultural Research (ICAR) have successfully developed new drought-resistant crop varieties that promise to revolutionize farming in water-scarce regions. These innovative varieties, including wheat, rice, and pulses, have been specifically bred to withstand prolonged dry spells while maintaining high yields.\n\n\n\nThe new varieties are the result of five years of intensive research and field trials across multiple states. Field tests in Rajasthan, Maharashtra, and Karnataka have shown promising results, with yields remaining stable even during 30% water shortage conditions.\n\n\n\nFarmers who participated in the trials reported significant water savings and improved crop resilience. The new varieties are expected to be available for commercial cultivation in the upcoming season. Government subsidies and support programs are being planned to help farmers adopt these climate-resilient crops.',
          sources: [
            'https://icar.org.in',
            'https://agriculture.gov.in',
          ],
        ),
        NewsCard(
          id: 'news_2',
          imageUrl:
              'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=1200&q=80',
          title: 'Monsoon Forecast: Heavy Rains Expected in Western India',
          description:
              'IMD predicts above-normal monsoon rainfall in western states. Farmers advised to prepare for heavy rains and potential flooding.',
          fullContent:
              'The India Meteorological Department (IMD) has issued a forecast predicting above-normal monsoon rainfall for western India, including Maharashtra, Gujarat, and parts of Rajasthan. The monsoon season is expected to bring 110-115% of the long-period average rainfall.\n\n\n\nFarmers are advised to take several precautionary measures:\n\n- Ensure proper drainage systems in fields\n- Harvest ready crops before heavy rains\n- Store harvested produce in dry, elevated areas\n- Prepare for potential pest and disease outbreaks\n- Review crop insurance policies\n\n\n\nAgricultural experts recommend adjusting planting schedules and considering flood-resistant crop varieties. The state agriculture departments are organizing awareness camps and providing advisory services to help farmers prepare for the upcoming monsoon season.\n\n\n\nWhile the heavy rainfall is expected to benefit water reservoirs and groundwater levels, farmers need to be vigilant about crop protection and soil erosion management.',
          sources: [
            'https://mausam.imd.gov.in',
            'https://agriculture.gov.in',
          ],
        ),
        NewsCard(
          id: 'news_3',
          imageUrl:
              'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=1200&q=80',
          title: 'Organic Farming Revolution: Young Farmers Lead the Way',
          description:
              'Organic farming is gaining massive popularity among young farmers across India. Government schemes and market demand are driving this sustainable agriculture movement.',
          fullContent:
              'A new generation of farmers is transforming Indian agriculture by embracing organic farming practices. Young agricultural entrepreneurs, many with technical backgrounds, are leading this movement towards sustainable and chemical-free farming.\n\n\n\nKey factors driving this trend include:\n\n- Growing consumer demand for organic produce\n- Government subsidies and certification support\n- Better profit margins for organic crops\n- Environmental consciousness among young farmers\n- Support from agricultural startups and e-commerce platforms\n\n\n\nSuccess stories from organic farmers show 20-30% higher profits compared to conventional farming, despite initial challenges. The organic food market in India is growing at 25% annually, providing excellent opportunities for farmers.\n\n\n\nGovernment initiatives like the Paramparagat Krishi Vikas Yojana (PKVY) are providing financial assistance and training to farmers transitioning to organic methods. Many farmers are also forming cooperatives to share knowledge and access better markets.\n\n\n\nAgricultural experts emphasize the importance of proper training and gradual transition to organic methods for sustainable success.',
          sources: [
            'https://agriculture.gov.in',
            'https://www.apeda.gov.in',
          ],
        ),
        NewsCard(
          id: 'news_4',
          imageUrl:
              'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&w=1200&q=80',
          title: 'Smart Irrigation Systems Reduce Water Usage by 40%',
          description:
              'Farmers using IoT-based smart irrigation systems report significant water savings. Technology adoption is accelerating in precision agriculture.',
          fullContent:
              'Revolutionary smart irrigation systems powered by Internet of Things (IoT) technology are helping farmers across India reduce water consumption by up to 40% while improving crop yields. These systems use sensors to monitor soil moisture, weather conditions, and crop needs in real-time.\n\n\n\nHow Smart Irrigation Works:\n\n- Soil moisture sensors detect water levels in fields\n- Weather stations provide local climate data\n- Mobile apps allow remote monitoring and control\n- Automated irrigation systems water crops only when needed\n- Data analytics optimize irrigation schedules\n\n\n\nFarmers in water-stressed regions like Punjab, Haryana, and Tamil Nadu are experiencing remarkable benefits. Case studies show that smart irrigation not only conserves water but also reduces electricity costs by 30% and increases crop productivity by 15-20%.\n\n\n\nThe government\'s Pradhan Mantri Krishi Sinchayee Yojana (PMKSY) is promoting micro-irrigation systems, with subsidies up to 55% for small and marginal farmers. Several startups are also offering affordable smart irrigation solutions tailored for Indian farms.\n\n\n\nAgricultural experts predict that widespread adoption of smart irrigation could solve India\'s water crisis in agriculture while ensuring food security for the growing population.',
          sources: [
            'https://pmksy.gov.in',
            'https://agriculture.gov.in',
          ],
        ),
        NewsCard(
          id: 'news_5',
          imageUrl:
              'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=1200&q=80',
          title: 'Record Harvest: Wheat Production Reaches All-Time High',
          description:
              'India achieves record wheat production this season, with farmers celebrating bumper harvests. Government announces MSP increases for major crops.',
          fullContent:
              'India has achieved a historic milestone in wheat production, recording the highest-ever harvest this season. The record production comes as excellent news for the agricultural sector and food security.\n\n\n\nKey highlights:\n\n- Wheat production increased by 8% compared to last year\n- Record production in states of Punjab, Haryana, and Uttar Pradesh\n- Favorable weather conditions and improved farming practices contributed\n- Government procurement targets exceeded\n\n\n\nThe Ministry of Agriculture has attributed this success to several factors including favorable monsoon patterns, timely government support, adoption of improved seed varieties, and better pest management practices.\n\n\n\nIn a related development, the government has announced increases in Minimum Support Prices (MSP) for major crops including wheat, rice, pulses, and oilseeds. The MSP for wheat has been increased by ₹150 per quintal, providing better returns to farmers.\n\n\n\nThis record production is expected to strengthen India\'s food security and may also create export opportunities. The government is working on storage and logistics infrastructure to handle the increased production efficiently.\n\n\n\nFarmers are being encouraged to diversify crops and maintain sustainable farming practices to ensure continued success in future seasons.',
          sources: [
            'https://agriculture.gov.in',
            'https://fci.gov.in',
          ],
        ),
        NewsCard(
          id: 'news_6',
          imageUrl:
              'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=1200&q=80',
          title: 'Drones Revolutionize Crop Monitoring and Spraying',
          description:
              'Agricultural drones are transforming crop management. Farmers using drone technology report 50% reduction in pesticide usage and improved crop health monitoring.',
          fullContent:
              'Agricultural drones are revolutionizing farming practices across India, offering farmers efficient and cost-effective solutions for crop monitoring, spraying, and field management. The adoption of drone technology in agriculture is accelerating rapidly.\n\n\n\nBenefits of Agricultural Drones:\n\n- Precise pesticide and fertilizer application\n- Real-time crop health monitoring\n- Early detection of pest infestations and diseases\n- Field mapping and soil analysis\n- Reduced labor costs and time\n- Safety improvements for farmers\n\n\n\nGovernment initiatives like the Drone Shakti scheme are promoting drone technology in agriculture. The government has also simplified regulations, making it easier for farmers to use drones for agricultural purposes.\n\n\n\nSuccess stories from farmers show remarkable improvements:\n\n- 50% reduction in pesticide usage through targeted spraying\n- 30% reduction in overall farming costs\n- 20% increase in crop yields\n- Significant time savings in field monitoring\n\n\n\nDrone service providers are offering affordable rental and service models, making this technology accessible to even small and marginal farmers. Training programs are being conducted to help farmers and agricultural workers learn drone operation.\n\n\n\nThe future of Indian agriculture looks promising with the integration of drone technology, promising more efficient, sustainable, and profitable farming practices.',
          sources: [
            'https://civilaviation.gov.in',
            'https://agriculture.gov.in',
          ],
        ),
        NewsCard(
          id: 'news_7',
          imageUrl:
              'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80',
          title: 'Solar-Powered Pumps Help Farmers Cut Electricity Costs',
          description:
              'Solar-powered irrigation pumps are helping farmers reduce electricity bills significantly. Government subsidies making solar pumps affordable for small farmers.',
          fullContent:
              'Solar-powered irrigation pumps are emerging as a game-changer for Indian farmers, significantly reducing electricity costs while providing reliable water supply for irrigation. The government\'s KUSUM (Kisan Urja Suraksha evam Utthaan Mahabhiyan) scheme is driving widespread adoption.\n\n\n\nAdvantages of Solar Pumps:\n\n- Zero electricity bills for irrigation\n- Reliable power supply in remote areas\n- Low maintenance costs\n- Environmentally friendly\n- Long-term cost savings\n\n\n\nUnder the KUSUM scheme, farmers receive subsidies up to 60% for installing solar pumps. The government aims to install 2 million solar pumps across the country, helping millions of farmers reduce their operational costs.\n\n\n\nFarmers who have installed solar pumps report:\n\n- 100% reduction in electricity bills for irrigation\n- Increased irrigation capacity\n- Ability to irrigate more crops per season\n- Better financial stability\n\n\n\nThe scheme also allows farmers to sell excess solar power to the grid, creating an additional income source. This innovative approach is helping farmers become energy-independent while contributing to India\'s renewable energy goals.\n\n\n\nAgricultural experts emphasize that solar pumps are particularly beneficial in areas with frequent power cuts or unreliable electricity supply, ensuring uninterrupted irrigation during critical crop growth stages.',
          sources: [
            'https://kusum.mnre.gov.in',
            'https://mnre.gov.in',
          ],
        ),
        NewsCard(
          id: 'news_8',
          imageUrl:
              'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=1200&q=80',
          title: 'Direct-to-Consumer Platforms Empower Farmers',
          description:
              'Farm-to-fork platforms are connecting farmers directly with consumers, eliminating middlemen and improving farmer incomes by 30-40%.',
          fullContent:
              'Digital platforms connecting farmers directly with consumers are revolutionizing agricultural marketing in India. These farm-to-fork platforms are eliminating intermediaries and ensuring better prices for farmers while providing fresh produce to consumers.\n\n\n\nHow Direct-to-Consumer Platforms Work:\n\n- Farmers list their produce on digital platforms\n- Consumers place orders directly from farmers\n- Fresh produce delivered to consumers\' doorsteps\n- Transparent pricing and fair compensation\n- Quality assurance and traceability\n\n\n\nBenefits for Farmers:\n\n- 30-40% increase in income\n- Better price realization\n- Direct access to urban markets\n- Reduced post-harvest losses\n- Regular demand and predictable sales\n\n\n\nPopular platforms like various e-commerce and agricultural startups are working with thousands of farmers across states. These platforms provide logistics support, quality control, and payment processing services.\n\n\n\nGovernment initiatives like the National Agriculture Market (eNAM) are also promoting digital trading platforms. The integration of technology is making agricultural marketing more efficient and farmer-friendly.\n\n\n\nConsumers benefit from fresh, traceable produce at competitive prices, while farmers get fair compensation for their hard work. This direct connection is creating a win-win situation for both farmers and consumers, transforming the agricultural supply chain.',
          sources: [
            'https://enam.gov.in',
            'https://agriculture.gov.in',
          ],
        ),
      ],
    );
  }
}

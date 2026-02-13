import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselReviewDemo extends StatefulWidget {
  @override
  _CarouselReviewDemoState createState() => _CarouselReviewDemoState();
}

class _CarouselReviewDemoState extends State<CarouselReviewDemo> {
  final List<Review> reviews = [
    Review(
      name: '张三',
      rating: 5,
      comment: '这个产品真的很好用，完全超出了我的预期。客服态度也非常好，推荐购买！这个评论比较长，用来测试高度不一致的情况。我们需要确保所有卡片都有相同的高度，无论评论内容有多长。这样用户在浏览时会有更好的体验。',
      date: '2025-10-01',
    ),
    Review(
      name: '李四',
      rating: 4,
      comment: '质量不错，物流也很快。有一点小瑕疵，但不影响使用。',
      date: '2025-09-28',
    ),
    Review(
      name: '王五',
      rating: 5,
      comment: '非常满意的一次购物体验，会推荐给朋友们的。这个评论也比较长，用来测试高度不一致的情况。我们需要确保所有卡片都有相同的高度，无论评论内容有多长。这样用户在浏览时会有更好的体验。而且还要确保内容可以滚动查看。',
      date: '2025-09-25',
    ),
    Review(
      name: '赵六',
      rating: 4,
      comment: '产品功能齐全，操作简单，性价比很高。',
      date: '2025-09-20',
    ),
    Review(
      name: '孙七',
      rating: 5,
      comment: '物流超快，第二天就到了。产品质量很好，包装也很仔细。这个评论同样比较长，用来测试高度不一致的情况。我们需要确保所有卡片都有相同的高度，无论评论内容有多长。这样用户在浏览时会有更好的体验。',
      date: '2025-09-18',
    ),
  ];

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('好评自动轮播组件'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户好评',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            Text(
              '自动轮播的好评展示组件，当前项目不会放大显示',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 30),
            Expanded(
              child: Center(
                child: CarouselSlider(
                  items: reviews.map((review) => _buildReviewCard(review)).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: false,
                    scrollDirection: Axis.horizontal,
                    viewportFraction: 1.0, // Changed from 0.8 to 1.0 to show only one item
                    aspectRatio: 1.2,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: reviews.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => {}, // 可以添加点击跳转功能
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == entry.key 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              '特性说明',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            _buildFeatureItem('自动轮播', '每3秒自动切换到下一个评价'),
            _buildFeatureItem('不放大当前项', '所有项目保持相同大小显示'),
            _buildFeatureItem('高度一致性', '所有卡片保持相同高度，内容可滚动查看'),
            _buildFeatureItem('指示器', '底部圆点指示当前显示的项目'),
            _buildFeatureItem('平滑动画', '切换时有平滑的过渡动画'),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0), // Changed from 0.0 to 10.0 for spacing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  review.date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: index < review.rating ? Colors.amber : Colors.grey,
                  size: 20,
                );
              }),
            ),
            SizedBox(height: 15),
            // Use Expanded to ensure consistent height and allow scrolling for long content
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  review.comment,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Review {
  final String name;
  final int rating;
  final String comment;
  final String date;

  Review({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
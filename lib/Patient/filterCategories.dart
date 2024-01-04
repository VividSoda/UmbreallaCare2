import 'package:flutter/material.dart';
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/Models/categoryButtons.dart';
class FilterCategories extends StatefulWidget {
  const FilterCategories({Key? key}) : super(key: key);
  @override
  State<FilterCategories> createState() => _FilterCategoriesState();
}
class _FilterCategoriesState extends State<FilterCategories> {
  int? _currentIndex;
  String? _category = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed:() {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: primary,
            )
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: primary
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: (){
                  Navigator.of(context).pop(_category);
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primary
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Wrap(
              children: List.generate(
                  categoryButtons.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                _currentIndex = index;
                                _category = categoryButtons[index].name;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              width: MediaQuery.of(context).size.width/5.1,
                              height: 105,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: primary
                                ),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    height: 56,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: primary
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      color: _currentIndex == index? primary : null
                                    ),
                                    child: Image.asset(
                                      categoryButtons[index].imgPath,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Expanded(
                                    child: Text(
                                      categoryButtons[index].name,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width/40,
                                        fontWeight: FontWeight.w400,
                                        color: primary
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
              )
            ),
          )
        ),
      ),
    );
  }
}

class CategoryButtons {
  String name, imgPath;

  CategoryButtons(this.name, this.imgPath);
}

List<CategoryButtons> categoryButtons = categoriesData
    .map((item) => CategoryButtons(item['name']!, item['imgPath']!))
    .toList();
var categoriesData = [
  {
    'name': 'Pediatrician',
    'imgPath': 'assets/filterCategories/pediatrician.png'
  },
  {'name': 'Psychiatry', 'imgPath': 'assets/filterCategories/psychiatry.png'},
  {
    'name': 'Dermatologist',
    'imgPath': 'assets/filterCategories/dermatology.png'
  },
  {
    'name': 'Gynaecologist',
    'imgPath': 'assets/filterCategories/gynaecology.png'
  },
  {'name': 'Radiologist', 'imgPath': 'assets/filterCategories/x-ray.png'},
  {'name': 'Orthopedics', 'imgPath': 'assets/filterCategories/orthopedics.png'},
  {'name': 'General Surgery', 'imgPath': 'assets/filterCategories/surgery.png'},
  {'name': 'Urologist', 'imgPath': 'assets/filterCategories/urology.png'},
  {'name': 'ENT', 'imgPath': 'assets/filterCategories/ENT.png'},
  {
    'name': 'Ophthalmologist',
    'imgPath': 'assets/filterCategories/ophthalmologist.png'
  },
  {
    'name': 'Endocrinologist',
    'imgPath': 'assets/filterCategories/endocrinology.png'
  },
  {
    'name': 'Pulmonologist',
    'imgPath': 'assets/filterCategories/pulmonology.png'
  },
  {'name': 'Cardiologist', 'imgPath': 'assets/filterCategories/cardiology.png'},
  {
    'name': 'Breast Oncosurgery',
    'imgPath': 'assets/filterCategories/breast oncosurgey.png'
  },
  {'name': 'Physician', 'imgPath': 'assets/filterCategories/physician.png'},
  {'name': 'Neurology', 'imgPath': 'assets/filterCategories/neurology.png'},
  {'name': 'Oncology', 'imgPath': 'assets/filterCategories/oncology.png'},
  {
    'name': 'Gastroenterology',
    'imgPath': 'assets/filterCategories/gastroenterology.png'
  },
  {'name': 'Allergist', 'imgPath': 'assets/filterCategories/allergist.png'},
  {
    'name': 'Immunologist',
    'imgPath': 'assets/filterCategories/immunologist.png'
  },
  {
    'name': 'Anesthesiology',
    'imgPath': 'assets/filterCategories/anaesthesiology.png'
  },
  {'name': 'Nephrology', 'imgPath': 'assets/filterCategories/nephrology.png'},
  {
    'name': 'Rheumatology',
    'imgPath': 'assets/filterCategories/rheumatology.png'
  },
  {'name': 'Hematology', 'imgPath': 'assets/filterCategories/hematology.png'},
];

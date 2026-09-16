import 'unit_model.dart';

/// المنهج الكامل لأرقامي: مسار تدريجي من تأسيس العدد في عمر 3 سنوات
/// إلى أساسيات الجبر والعمليات في عمر 16 سنة.
/// كل وحدة تحتوي على درس، أمثلة، تدريب، وأسئلة كوييز.
class UnitsData {
  static final List<UnitModel> units = [
    UnitModel(id: 'unit_01', order: 1, titleAr: 'الصفر والعدد 1', ageRangeAr: '3–4 سنوات', descriptionAr: 'فهم معنى الصفر والعدد 1 وكتابتهما.', activities: [
      LessonActivityConfig(titleAr: 'ما هو الصفر؟', explanationAr: 'الصفر يعني عدم وجود أي شيء، والعدد 1 يعني شيئًا واحدًا.', examplesAr: ['0 تفاحات', '1 تفاحة']),
      TraceActivityConfig(0), TraceActivityConfig(1),
      MatchingActivityConfig([MatchPairSpec(id: '0', leftType: MatchContentType.number, leftValue: 0, rightType: MatchContentType.quantity, rightValue: 0), MatchPairSpec(id: '1', leftType: MatchContentType.number, leftValue: 1, rightType: MatchContentType.quantity, rightValue: 1)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 1', questions: [ChoiceQuestion(questionAr: 'ماذا يعني 0؟', options: ['لا شيء', 'شيء واحد', 'شيئان'], correctIndex: 0), ChoiceQuestion(questionAr: 'كم تفاحة هنا؟ 1', options: ['0', '1', '2'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_02', order: 2, titleAr: 'العد 0–3', ageRangeAr: '3–4 سنوات', descriptionAr: 'العد بترتيب صحيح من 0 إلى 3.', activities: [
      LessonActivityConfig(titleAr: 'نعد معًا', explanationAr: 'نبدأ من 0 ثم ننتقل إلى 1 ثم 2 ثم 3.', examplesAr: ['0، 1، 2، 3']),
      TraceActivityConfig(2), TraceActivityConfig(3), DragCountActivityConfig(3),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 2', questions: [ChoiceQuestion(questionAr: 'ما العدد بعد 1؟', options: ['0', '2', '3'], correctIndex: 1), ChoiceQuestion(questionAr: 'ما العدد قبل 3؟', options: ['1', '2', '4'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_03', order: 3, titleAr: 'الأعداد 4 و5', ageRangeAr: '3–5 سنوات', descriptionAr: 'التعرف على 4 و5 وكتابتهما وربطهما بالكميات.', activities: [
      LessonActivityConfig(titleAr: 'نتعرف على 4 و5', explanationAr: 'العدد 4 يعني أربع وحدات، والعدد 5 يعني خمس وحدات.', examplesAr: ['4 تفاحات', '5 أقلام']),
      TraceActivityConfig(4), TraceActivityConfig(5), DragCountActivityConfig(5),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 3', questions: [ChoiceQuestion(questionAr: 'أي عدد يأتي بعد 4؟', options: ['3', '5', '6'], correctIndex: 1), ChoiceQuestion(questionAr: 'أي كمية تمثل 5؟', options: ['3', '4', '5'], correctIndex: 2)]),
    ]),
    UnitModel(id: 'unit_04', order: 4, titleAr: 'الأعداد 6 و7', ageRangeAr: '4–5 سنوات', descriptionAr: 'التعرف على 6 و7 وربطهما بالكميات.', activities: [
      LessonActivityConfig(titleAr: 'نتعرف على 6 و7', explanationAr: 'نعد ست وحدات ثم سبع وحدات ونتعلم كتابة الرقمين.', examplesAr: ['6 كرات', '7 نجوم']),
      TraceActivityConfig(6), TraceActivityConfig(7), DragCountActivityConfig(7),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 4', questions: [ChoiceQuestion(questionAr: 'أي عدد أكبر؟', options: ['5', '6', '4'], correctIndex: 1), ChoiceQuestion(questionAr: 'ما العدد الذي يأتي بعد 6؟', options: ['5', '7', '8'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_05', order: 5, titleAr: 'الأعداد 8 و9', ageRangeAr: '4–5 سنوات', descriptionAr: 'التعرف على 8 و9 والاستعداد للعدد 10.', activities: [
      LessonActivityConfig(titleAr: 'نتعرف على 8 و9', explanationAr: 'ثماني وحدات تساوي 8، وتسع وحدات تساوي 9.', examplesAr: ['8 كتب', '9 أقلام']),
      TraceActivityConfig(8), TraceActivityConfig(9), DragCountActivityConfig(9),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 5', questions: [ChoiceQuestion(questionAr: 'ما العدد قبل 9؟', options: ['7', '8', '10'], correctIndex: 1), ChoiceQuestion(questionAr: 'أي عدد أكبر؟', options: ['8', '6', '5'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_06', order: 6, titleAr: 'العدد 10 ومفهوم العشرة', ageRangeAr: '4–6 سنوات', descriptionAr: 'فهم أن 10 وحدات تكوّن مجموعة من عشرة.', activities: [
      LessonActivityConfig(titleAr: 'ما هي العشرة؟', explanationAr: 'عندما نجمع 10 أشياء نحصل على مجموعة واحدة من عشرة.', examplesAr: ['10 أصابع', '10 ألعاب']),
      TraceActivityConfig(1), TraceActivityConfig(0), DragCountActivityConfig(10),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 6', questions: [ChoiceQuestion(questionAr: 'كم وحدة في العشرة؟', options: ['8', '9', '10'], correctIndex: 2), ChoiceQuestion(questionAr: 'ما العدد بعد 9؟', options: ['8', '10', '11'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_07', order: 7, titleAr: 'مراجعة الأعداد 0–10', ageRangeAr: '4–6 سنوات', descriptionAr: 'مراجعة قراءة وكتابة ومقارنة الأعداد من 0 إلى 10.', activities: [
      LessonActivityConfig(titleAr: 'مراجعة شاملة', explanationAr: 'نراجع العد والترتيب والمقارنة والكمية قبل الانتقال إلى العشرات.', examplesAr: ['0، 2، 5، 10']),
      MatchingActivityConfig([MatchPairSpec(id: '2', leftType: MatchContentType.number, leftValue: 2, rightType: MatchContentType.quantity, rightValue: 2), MatchPairSpec(id: '6', leftType: MatchContentType.number, leftValue: 6, rightType: MatchContentType.quantity, rightValue: 6), MatchPairSpec(id: '10', leftType: MatchContentType.number, leftValue: 10, rightType: MatchContentType.quantity, rightValue: 10)]),
      ComparisonActivityConfig(leftCount: 3, rightCount: 7, question: ComparisonQuestionType.fewer),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 7', questions: [ChoiceQuestion(questionAr: 'ما العدد الذي يأتي بعد 6؟', options: ['5', '7', '9'], correctIndex: 1), ChoiceQuestion(questionAr: 'أي عدد أكبر؟', options: ['3', '8', '2'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_08', order: 8, titleAr: 'الآحاد والعشرات', ageRangeAr: '5–7 سنوات', descriptionAr: 'فهم القيمة المكانية للآحاد والعشرات.', activities: [
      LessonActivityConfig(titleAr: 'القيمة المكانية', explanationAr: 'كل عدد من خانتين يتكون من عشرات وآحاد.', examplesAr: ['24 = 2 عشرات و4 آحاد', '50 = 5 عشرات و0 آحاد']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 8', questions: [ChoiceQuestion(questionAr: 'كم عشرة في 24؟', options: ['2', '4', '24'], correctIndex: 0), ChoiceQuestion(questionAr: 'ما قيمة 4 في 24؟', options: ['4', '40', '24'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_09', order: 9, titleAr: 'الأعداد 11–20', ageRangeAr: '5–7 سنوات', descriptionAr: 'قراءة وبناء الأعداد من 11 إلى 20.', activities: [
      LessonActivityConfig(titleAr: 'من 11 إلى 20', explanationAr: 'نبني العدد من عشرة واحدة وآحاد إضافية حتى نصل إلى 20.', examplesAr: ['11 = 10 + 1', '20 = 2 عشرات']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '10 + 3 = ؟', correctAnswer: 13), ArithmeticQuestion(questionAr: '10 + 7 = ؟', correctAnswer: 17)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 9', questions: [ChoiceQuestion(questionAr: '10 + 3 يساوي؟', options: ['12', '13', '14'], correctIndex: 1), ChoiceQuestion(questionAr: 'كم عشرة في 20؟', options: ['1', '2', '20'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_10', order: 10, titleAr: 'الأعداد 21–50', ageRangeAr: '5–7 سنوات', descriptionAr: 'قراءة وتحليل الأعداد من 21 إلى 50.', activities: [
      LessonActivityConfig(titleAr: 'نبني الأعداد', explanationAr: 'نفكك العدد إلى عشرات وآحاد ثم نعيد تركيبه.', examplesAr: ['34 = 30 + 4', '47 = 40 + 7']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '30 + 4 = ؟', correctAnswer: 34), ArithmeticQuestion(questionAr: '40 + 7 = ؟', correctAnswer: 47)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 10', questions: [ChoiceQuestion(questionAr: '34 فيه كم عشرة؟', options: ['3', '4', '34'], correctIndex: 0), ChoiceQuestion(questionAr: '40 + 7 يساوي؟', options: ['47', '74', '37'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_11', order: 11, titleAr: 'الأعداد 51–99', ageRangeAr: '5–7 سنوات', descriptionAr: 'إتقان قراءة وكتابة الأعداد ذات الخانتين.', activities: [
      LessonActivityConfig(titleAr: 'حتى 99', explanationAr: 'نقرأ العشرات أولًا ثم الآحاد ونفكك العدد.', examplesAr: ['58 = 50 + 8', '99 = 90 + 9']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '50 + 8 = ؟', correctAnswer: 58), ArithmeticQuestion(questionAr: '90 + 9 = ؟', correctAnswer: 99)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 11', questions: [ChoiceQuestion(questionAr: '50 + 8 يساوي؟', options: ['58', '85', '50'], correctIndex: 0), ChoiceQuestion(questionAr: 'ما العدد الأكبر؟', options: ['89', '98', '88'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_12', order: 12, titleAr: 'ترتيب ومقارنة الأعداد حتى 100', ageRangeAr: '6–8 سنوات', descriptionAr: 'مقارنة الأعداد وترتيبها باستخدام القيمة المكانية.', activities: [
      LessonActivityConfig(titleAr: 'أيهما أكبر؟', explanationAr: 'نقارن العشرات أولًا، وإذا تساوت نقارن الآحاد.', examplesAr: ['63 > 36', '79 < 80']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 12', questions: [ChoiceQuestion(questionAr: 'أي عدد أكبر؟', options: ['36', '63', '26'], correctIndex: 1), ChoiceQuestion(questionAr: 'ما العدد بعد 79؟', options: ['78', '80', '89'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_13', order: 13, titleAr: 'مراجعة الأعداد حتى 100', ageRangeAr: '6–8 سنوات', descriptionAr: 'تثبيت العد والعشرات والآحاد والمقارنة.', activities: [
      LessonActivityConfig(titleAr: 'مراجعة العشرات', explanationAr: 'نراجع بناء العدد وقراءته وترتيبه قبل الانتقال إلى المئات.', examplesAr: ['80 = 8 عشرات', '47 = 4 عشرات و7 آحاد']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 13', questions: [ChoiceQuestion(questionAr: 'كم عشرة في 80؟', options: ['6', '8', '10'], correctIndex: 1), ChoiceQuestion(questionAr: 'أي عدد أصغر؟', options: ['71', '17', '70'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_14', order: 14, titleAr: 'مفهوم المئات', ageRangeAr: '7–9 سنوات', descriptionAr: 'فهم أن 100 وحدة تساوي 10 عشرات.', activities: [
      LessonActivityConfig(titleAr: 'المئات', explanationAr: 'المئة مجموعة من 100 وحدة، وهي أيضًا 10 عشرات.', examplesAr: ['100 = مئة', '200 = مئتان']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '100 + 100 = ؟', correctAnswer: 200)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 14', questions: [ChoiceQuestion(questionAr: 'كم عشرة في 100؟', options: ['5', '10', '100'], correctIndex: 1), ChoiceQuestion(questionAr: '100 + 100 يساوي؟', options: ['200', '110', '101'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_15', order: 15, titleAr: 'الأعداد حتى 500', ageRangeAr: '7–9 سنوات', descriptionAr: 'بناء وقراءة الأعداد من 100 إلى 500.', activities: [
      LessonActivityConfig(titleAr: 'نبني المئات', explanationAr: 'نستخدم المئات والعشرات والآحاد لبناء العدد.', examplesAr: ['125 = 100 + 20 + 5', '340 = 300 + 40']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '100 + 20 + 5 = ؟', correctAnswer: 125), ArithmeticQuestion(questionAr: '300 + 40 = ؟', correctAnswer: 340)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 15', questions: [ChoiceQuestion(questionAr: '100 + 20 + 5 يساوي؟', options: ['125', '152', '105'], correctIndex: 0), ChoiceQuestion(questionAr: 'أي عدد أكبر؟', options: ['250', '205', '205'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_16', order: 16, titleAr: 'الأعداد حتى 999', ageRangeAr: '7–9 سنوات', descriptionAr: 'قراءة وكتابة الأعداد ذات ثلاث خانات.', activities: [
      LessonActivityConfig(titleAr: 'ثلاث خانات', explanationAr: 'كل عدد من ثلاث خانات يتكون من مئات وعشرات وآحاد.', examplesAr: ['348 = 300 + 40 + 8', '705 = 700 + 5']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '300 + 40 + 8 = ؟', correctAnswer: 348)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 16', questions: [ChoiceQuestion(questionAr: '300 + 40 + 8 يساوي؟', options: ['348', '384', '438'], correctIndex: 0), ChoiceQuestion(questionAr: 'ما قيمة 7 في 705؟', options: ['7', '70', '700'], correctIndex: 2)]),
    ]),
    UnitModel(id: 'unit_17', order: 17, titleAr: 'القيمة المكانية حتى 999', ageRangeAr: '7–10 سنوات', descriptionAr: 'تمييز قيمة الرقم حسب موقعه في العدد.', activities: [
      LessonActivityConfig(titleAr: 'القيمة المكانية', explanationAr: 'قيمة الرقم تتغير حسب مكانه: مئات أو عشرات أو آحاد.', examplesAr: ['542: الرقم 4 قيمته 40', '731: الرقم 7 قيمته 700']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 17', questions: [ChoiceQuestion(questionAr: 'ما قيمة 4 في 542؟', options: ['4', '40', '400'], correctIndex: 1), ChoiceQuestion(questionAr: 'ما قيمة 7 في 731؟', options: ['7', '70', '700'], correctIndex: 2)]),
    ]),
    UnitModel(id: 'unit_18', order: 18, titleAr: 'مراجعة المئات', ageRangeAr: '7–10 سنوات', descriptionAr: 'مراجعة الأعداد والقيمة المكانية حتى 999.', activities: [
      LessonActivityConfig(titleAr: 'مراجعة حتى 999', explanationAr: 'نراجع المئات والعشرات والآحاد والمقارنة.', examplesAr: ['409 < 490', '904 أكبر من 490']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 18', questions: [ChoiceQuestion(questionAr: 'أي عدد أكبر؟', options: ['409', '490', '904'], correctIndex: 2), ChoiceQuestion(questionAr: 'ما قيمة 9 في 490؟', options: ['9', '90', '900'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_19', order: 19, titleAr: 'مفهوم الألف', ageRangeAr: '8–11 سنة', descriptionAr: 'فهم الألف وعلاقته بالمئات.', activities: [
      LessonActivityConfig(titleAr: 'الألف', explanationAr: 'ألف وحدة تساوي 10 مئات.', examplesAr: ['1,000 = ألف', '2,000 = ألفان']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '1,000 + 1,000 = ؟', correctAnswer: 2000)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 19', questions: [ChoiceQuestion(questionAr: 'كم مئة في 1,000؟', options: ['5', '10', '100'], correctIndex: 1), ChoiceQuestion(questionAr: '1,000 + 1,000 يساوي؟', options: ['1,100', '2,000', '10,000'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_20', order: 20, titleAr: 'الأعداد حتى 9,999', ageRangeAr: '8–11 سنة', descriptionAr: 'قراءة وكتابة الأعداد ذات أربع خانات.', activities: [
      LessonActivityConfig(titleAr: 'الآلاف والمئات والعشرات والآحاد', explanationAr: 'نحدد قيمة كل خانة لبناء العدد وقراءته بدقة.', examplesAr: ['4,582 = 4,000 + 500 + 80 + 2', '7,245 = 7,000 + 200 + 40 + 5']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '4,000 + 500 + 80 + 2 = ؟', correctAnswer: 4582)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 20', questions: [ChoiceQuestion(questionAr: '4,000 + 500 + 80 + 2 يساوي؟', options: ['4,582', '4,852', '4,285'], correctIndex: 0), ChoiceQuestion(questionAr: 'ما قيمة 2 في 7,245؟', options: ['2', '20', '200'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_21', order: 21, titleAr: 'مقارنة وترتيب الآلاف', ageRangeAr: '8–11 سنة', descriptionAr: 'مقارنة الأعداد حتى 9,999 وترتيبها.', activities: [
      LessonActivityConfig(titleAr: 'نقارن من اليسار', explanationAr: 'نبدأ بخانة الآلاف ثم المئات ثم العشرات ثم الآحاد.', examplesAr: ['2,190 < 2,901', '3,500 > 3,050']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 21', questions: [ChoiceQuestion(questionAr: 'أي عدد أصغر؟', options: ['2,901', '2,190', '2,910'], correctIndex: 1), ChoiceQuestion(questionAr: 'أي عدد أكبر؟', options: ['3,050', '3,005', '3,500'], correctIndex: 2)]),
    ]),
    UnitModel(id: 'unit_22', order: 22, titleAr: 'مراجعة الآلاف', ageRangeAr: '8–11 سنة', descriptionAr: 'تثبيت القيمة المكانية للأعداد ذات أربع خانات.', activities: [
      LessonActivityConfig(titleAr: 'مراجعة حتى 9,999', explanationAr: 'نراجع قراءة الأعداد وتحليلها ومقارنتها.', examplesAr: ['7,245 = 7,000 + 200 + 40 + 5', '5,080 = 5,000 + 80']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 22', questions: [ChoiceQuestion(questionAr: 'ما قيمة 7 في 7,245؟', options: ['7', '70', '7,000'], correctIndex: 2), ChoiceQuestion(questionAr: '5,000 + 80 يساوي؟', options: ['5,080', '5,800', '580'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_23', order: 23, titleAr: 'الجمع: مفهومه', ageRangeAr: '7–10 سنوات', descriptionAr: 'فهم الجمع كضم كميتين أو أكثر.', activities: [
      LessonActivityConfig(titleAr: 'الجمع', explanationAr: 'نجمع الكميات لنجد المجموع.', examplesAr: ['3 + 2 = 5', '7 + 1 = 8']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '3 + 2 = ؟', correctAnswer: 5), ArithmeticQuestion(questionAr: '6 + 3 = ؟', correctAnswer: 9)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 23', questions: [ChoiceQuestion(questionAr: '3 + 2 يساوي؟', options: ['4', '5', '6'], correctIndex: 1), ChoiceQuestion(questionAr: '6 + 3 يساوي؟', options: ['8', '9', '10'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_24', order: 24, titleAr: 'الجمع بدون حمل', ageRangeAr: '7–10 سنوات', descriptionAr: 'إجراء الجمع دون الحاجة إلى الحمل.', activities: [
      LessonActivityConfig(titleAr: 'نجمع خطوة خطوة', explanationAr: 'نجمع كل خانة مع نظيرتها عندما لا نتجاوز 9.', examplesAr: ['23 + 14 = 37', '120 + 230 = 350']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '23 + 14 = ؟', correctAnswer: 37), ArithmeticQuestion(questionAr: '120 + 230 = ؟', correctAnswer: 350), ArithmeticQuestion(questionAr: '214 + 123 = ؟', correctAnswer: 337)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 24', questions: [ChoiceQuestion(questionAr: '23 + 14 = ؟', options: ['37', '47', '27'], correctIndex: 0), ChoiceQuestion(questionAr: '120 + 230 = ؟', options: ['250', '350', '360'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_25', order: 25, titleAr: 'الجمع مع الحمل', ageRangeAr: '8–10 سنوات', descriptionAr: 'فهم الحمل عند تجاوز مجموع الخانة 9.', activities: [
      LessonActivityConfig(titleAr: 'الجمع مع الحمل', explanationAr: 'إذا أصبح مجموع الآحاد 10 أو أكثر، نكتب الآحاد ونحمل العشرة إلى الخانة التالية.', examplesAr: ['28 + 17 = 45', '156 + 287 = 443']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '28 + 17 = ؟', correctAnswer: 45), ArithmeticQuestion(questionAr: '156 + 287 = ؟', correctAnswer: 443)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 25', questions: [ChoiceQuestion(questionAr: '28 + 17 = ؟', options: ['35', '45', '55'], correctIndex: 1), ChoiceQuestion(questionAr: '156 + 287 = ؟', options: ['433', '443', '453'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_26', order: 26, titleAr: 'الطرح: مفهومه', ageRangeAr: '7–10 سنوات', descriptionAr: 'فهم الطرح كإزالة جزء ومعرفة الباقي.', activities: [
      LessonActivityConfig(titleAr: 'الطرح', explanationAr: 'نطرح جزءًا من كمية لمعرفة ما تبقى.', examplesAr: ['7 − 3 = 4', '10 − 6 = 4']),
      ArithmeticActivityConfig(operation: '-', questions: [ArithmeticQuestion(questionAr: '7 − 3 = ؟', correctAnswer: 4), ArithmeticQuestion(questionAr: '10 − 6 = ؟', correctAnswer: 4)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 26', questions: [ChoiceQuestion(questionAr: '7 − 3 يساوي؟', options: ['3', '4', '5'], correctIndex: 1), ChoiceQuestion(questionAr: '10 − 6 يساوي؟', options: ['3', '4', '6'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_27', order: 27, titleAr: 'الطرح بدون استلاف', ageRangeAr: '7–10 سنوات', descriptionAr: 'إجراء الطرح عندما تكون أرقام المطروح منها كافية.', activities: [
      LessonActivityConfig(titleAr: 'نطرح خانة بخانة', explanationAr: 'نطرح الآحاد ثم العشرات ثم المئات دون الحاجة إلى الاستلاف.', examplesAr: ['48 − 23 = 25', '560 − 120 = 440']),
      ArithmeticActivityConfig(operation: '-', questions: [ArithmeticQuestion(questionAr: '48 − 23 = ؟', correctAnswer: 25), ArithmeticQuestion(questionAr: '560 − 120 = ؟', correctAnswer: 440)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 27', questions: [ChoiceQuestion(questionAr: '48 − 23 = ؟', options: ['25', '35', '15'], correctIndex: 0), ChoiceQuestion(questionAr: '560 − 120 = ؟', options: ['430', '440', '450'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_28', order: 28, titleAr: 'الطرح مع الاستلاف', ageRangeAr: '8–10 سنوات', descriptionAr: 'فهم الاستلاف عند الحاجة إلى إعادة التجميع.', activities: [
      LessonActivityConfig(titleAr: 'الطرح مع الاستلاف', explanationAr: 'نحوّل عشرة من الخانة السابقة إلى 10 وحدات في الخانة الحالية.', examplesAr: ['52 − 28 = 24', '403 − 178 = 225']),
      ArithmeticActivityConfig(operation: '-', questions: [ArithmeticQuestion(questionAr: '52 − 28 = ؟', correctAnswer: 24), ArithmeticQuestion(questionAr: '403 − 178 = ؟', correctAnswer: 225)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 28', questions: [ChoiceQuestion(questionAr: '52 − 28 = ؟', options: ['24', '34', '14'], correctIndex: 0), ChoiceQuestion(questionAr: '403 − 178 = ؟', options: ['215', '225', '235'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_29', order: 29, titleAr: 'مسائل الجمع والطرح', ageRangeAr: '8–11 سنة', descriptionAr: 'اختيار العملية المناسبة وحل مسائل من الحياة اليومية.', activities: [
      LessonActivityConfig(titleAr: 'نختار العملية', explanationAr: 'نقرأ المسألة، نحدد المعطيات، نختار الجمع أو الطرح ثم نتحقق من الإجابة.', examplesAr: ['12 + 8 = 20', '30 − 12 = 18']),
      WordProblemActivityConfig([ArithmeticQuestion(questionAr: 'مع سارة 12 تفاحة، أعطتها أمها 8. كم أصبحت لديها؟', correctAnswer: 20), ArithmeticQuestion(questionAr: 'كان مع أحمد 30 درهمًا وأنفق 12. كم بقي؟', correctAnswer: 18)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 29', questions: [ChoiceQuestion(questionAr: 'مع سارة 12 تفاحة وأعطتها أمها 8. كم أصبحت لديها؟', options: ['18', '20', '22'], correctIndex: 1), ChoiceQuestion(questionAr: 'كان مع أحمد 30 درهمًا وأنفق 12. كم بقي؟', options: ['16', '18', '20'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_30', order: 30, titleAr: 'الضرب كمجموع متكرر', ageRangeAr: '8–11 سنة', descriptionAr: 'فهم الضرب كجمع متكرر لمجموعات متساوية.', activities: [
      LessonActivityConfig(titleAr: 'معنى الضرب', explanationAr: '3 × 4 تعني ثلاث مجموعات، في كل مجموعة 4.', examplesAr: ['3 × 4 = 4 + 4 + 4 = 12', '2 × 5 = 10']),
      ArithmeticActivityConfig(operation: '×', questions: [ArithmeticQuestion(questionAr: '3 × 4 = ؟', correctAnswer: 12), ArithmeticQuestion(questionAr: '2 × 5 = ؟', correctAnswer: 10)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 30', questions: [ChoiceQuestion(questionAr: '3 × 4 يساوي؟', options: ['7', '12', '14'], correctIndex: 1), ChoiceQuestion(questionAr: '2 × 5 يساوي؟', options: ['7', '10', '12'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_31', order: 31, titleAr: 'جداول الضرب 2 و5 و10', ageRangeAr: '8–11 سنة', descriptionAr: 'إتقان جداول الضرب الأساسية 2 و5 و10.', activities: [
      LessonActivityConfig(titleAr: 'الجداول الأساسية', explanationAr: 'نستخدم العد بالقفز لفهم أنماط الضرب.', examplesAr: ['7 × 2 = 14', '6 × 5 = 30', '8 × 10 = 80']),
      ArithmeticActivityConfig(operation: '×', questions: [ArithmeticQuestion(questionAr: '7 × 2 = ؟', correctAnswer: 14), ArithmeticQuestion(questionAr: '6 × 5 = ؟', correctAnswer: 30), ArithmeticQuestion(questionAr: '8 × 10 = ؟', correctAnswer: 80)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 31', questions: [ChoiceQuestion(questionAr: '7 × 2 = ؟', options: ['12', '14', '16'], correctIndex: 1), ChoiceQuestion(questionAr: '6 × 5 = ؟', options: ['25', '30', '35'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_32', order: 32, titleAr: 'جداول الضرب 3 و4 و6', ageRangeAr: '8–12 سنة', descriptionAr: 'إتقان جداول الضرب 3 و4 و6.', activities: [
      LessonActivityConfig(titleAr: 'نتدرب على الجداول', explanationAr: 'نربط كل عملية بمجموعات متساوية ونستخدم الحقائق المعروفة.', examplesAr: ['7 × 3 = 21', '8 × 4 = 32', '6 × 6 = 36']),
      ArithmeticActivityConfig(operation: '×', questions: [ArithmeticQuestion(questionAr: '7 × 3 = ؟', correctAnswer: 21), ArithmeticQuestion(questionAr: '8 × 4 = ؟', correctAnswer: 32), ArithmeticQuestion(questionAr: '6 × 6 = ؟', correctAnswer: 36)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 32', questions: [ChoiceQuestion(questionAr: '7 × 3 = ؟', options: ['18', '21', '24'], correctIndex: 1), ChoiceQuestion(questionAr: '8 × 4 = ؟', options: ['28', '32', '36'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_33', order: 33, titleAr: 'جداول الضرب 7 و8 و9', ageRangeAr: '9–12 سنة', descriptionAr: 'إتقان جداول الضرب 7 و8 و9.', activities: [
      LessonActivityConfig(titleAr: 'الجداول المتقدمة', explanationAr: 'نتدرب على الحقائق المتقاربة ونستخدم التبديل للتحقق.', examplesAr: ['7 × 7 = 49', '8 × 8 = 64', '9 × 9 = 81']),
      ArithmeticActivityConfig(operation: '×', questions: [ArithmeticQuestion(questionAr: '7 × 7 = ؟', correctAnswer: 49), ArithmeticQuestion(questionAr: '8 × 8 = ؟', correctAnswer: 64), ArithmeticQuestion(questionAr: '9 × 9 = ؟', correctAnswer: 81)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 33', questions: [ChoiceQuestion(questionAr: '7 × 7 = ؟', options: ['42', '49', '56'], correctIndex: 1), ChoiceQuestion(questionAr: '9 × 9 = ؟', options: ['72', '81', '90'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_34', order: 34, titleAr: 'الضرب في عدد من خانة', ageRangeAr: '9–12 سنة', descriptionAr: 'ضرب عدد متعدد الخانات في عدد من خانة واحدة.', activities: [
      LessonActivityConfig(titleAr: 'نضرب خانة بخانة', explanationAr: 'نبدأ بالآحاد ثم ننتقل إلى العشرات والمئات مع الحمل عند الحاجة.', examplesAr: ['24 × 3 = 72', '125 × 4 = 500']),
      ArithmeticActivityConfig(operation: '×', questions: [ArithmeticQuestion(questionAr: '24 × 3 = ؟', correctAnswer: 72), ArithmeticQuestion(questionAr: '125 × 4 = ؟', correctAnswer: 500)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 34', questions: [ChoiceQuestion(questionAr: '24 × 3 = ؟', options: ['62', '72', '82'], correctIndex: 1), ChoiceQuestion(questionAr: '125 × 4 = ؟', options: ['400', '500', '600'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_35', order: 35, titleAr: 'مفهوم القسمة', ageRangeAr: '9–12 سنة', descriptionAr: 'فهم القسمة كتوزيع متساو أو تجميع متساو.', activities: [
      LessonActivityConfig(titleAr: 'القسمة', explanationAr: 'نقسم الكمية إلى مجموعات متساوية لمعرفة عدد العناصر في كل مجموعة.', examplesAr: ['12 ÷ 3 = 4', '20 ÷ 5 = 4']),
      ArithmeticActivityConfig(operation: '÷', questions: [ArithmeticQuestion(questionAr: '12 ÷ 3 = ؟', correctAnswer: 4), ArithmeticQuestion(questionAr: '20 ÷ 5 = ؟', correctAnswer: 4)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 35', questions: [ChoiceQuestion(questionAr: '12 ÷ 3 = ؟', options: ['3', '4', '5'], correctIndex: 1), ChoiceQuestion(questionAr: '20 ÷ 5 = ؟', options: ['4', '5', '6'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_36', order: 36, titleAr: 'القسمة بدون باقي', ageRangeAr: '9–12 سنة', descriptionAr: 'إجراء القسمة الصحيحة عندما تتوزع الكمية دون باق.', activities: [
      LessonActivityConfig(titleAr: 'قسمة متساوية', explanationAr: 'إذا كان التوزيع متساويًا تمامًا يكون الباقي صفرًا.', examplesAr: ['20 ÷ 4 = 5', '72 ÷ 8 = 9']),
      ArithmeticActivityConfig(operation: '÷', questions: [ArithmeticQuestion(questionAr: '20 ÷ 4 = ؟', correctAnswer: 5), ArithmeticQuestion(questionAr: '72 ÷ 8 = ؟', correctAnswer: 9)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 36', questions: [ChoiceQuestion(questionAr: '20 ÷ 4 = ؟', options: ['4', '5', '6'], correctIndex: 1), ChoiceQuestion(questionAr: '72 ÷ 8 = ؟', options: ['8', '9', '10'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_37', order: 37, titleAr: 'القسمة مع الباقي', ageRangeAr: '10–12 سنة', descriptionAr: 'فهم الباقي وكتابته في مسائل القسمة.', activities: [
      LessonActivityConfig(titleAr: 'الباقي', explanationAr: 'إذا تعذر التوزيع الكامل، نكتب عدد المجموعات الكاملة وما تبقى.', examplesAr: ['14 ÷ 3 = 4 والباقي 2', '17 ÷ 5 = 3 والباقي 2']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 37', questions: [ChoiceQuestion(questionAr: '14 ÷ 3: كم مجموعة كاملة؟', options: ['3', '4', '5'], correctIndex: 1), ChoiceQuestion(questionAr: '14 ÷ 3: ما الباقي؟', options: ['1', '2', '3'], correctIndex: 1), ChoiceQuestion(questionAr: '17 ÷ 5 = ؟ والباقي؟', options: ['3 والباقي 2', '4 والباقي 1', '2 والباقي 7'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_38', order: 38, titleAr: 'مسائل الضرب والقسمة', ageRangeAr: '10–12 سنة', descriptionAr: 'اختيار الضرب أو القسمة لحل المسائل.', activities: [
      LessonActivityConfig(titleAr: 'نختار العملية', explanationAr: 'نبحث عن مجموعات متساوية: الضرب يبني المجموع، والقسمة توزعه.', examplesAr: ['6 × 8 = 48', '48 ÷ 6 = 8']),
      WordProblemActivityConfig([ArithmeticQuestion(questionAr: '6 صناديق، في كل صندوق 8 كرات. كم كرة؟', correctAnswer: 48), ArithmeticQuestion(questionAr: '48 كرة توزع على 6 أطفال. كم لكل طفل؟', correctAnswer: 8)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 38', questions: [ChoiceQuestion(questionAr: '6 صناديق في كل صندوق 8 كرات. كم كرة؟', options: ['42', '48', '56'], correctIndex: 1), ChoiceQuestion(questionAr: '48 كرة توزع على 6 أطفال. كم لكل طفل؟', options: ['6', '8', '9'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_39', order: 39, titleAr: 'مفهوم الكسور', ageRangeAr: '10–13 سنة', descriptionAr: 'فهم الكسر كجزء من كل متساوٍ.', activities: [
      LessonActivityConfig(titleAr: 'الكسر', explanationAr: 'الكسر يصف عدد الأجزاء المأخوذة مقارنة بعدد الأجزاء الكلي.', examplesAr: ['1/2 = نصف', '1/4 = ربع']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 39', questions: [ChoiceQuestion(questionAr: 'أي كسر يمثل نصفًا؟', options: ['1/2', '1/3', '1/4'], correctIndex: 0), ChoiceQuestion(questionAr: 'كم جزءًا في 1/4 من حيث المقام؟', options: ['2', '3', '4'], correctIndex: 2)]),
    ]),
    UnitModel(id: 'unit_40', order: 40, titleAr: 'البسط والمقام', ageRangeAr: '10–13 سنة', descriptionAr: 'تمييز البسط والمقام وفهم دور كل منهما.', activities: [
      LessonActivityConfig(titleAr: 'أجزاء الكسر', explanationAr: 'البسط في الأعلى ويخبرنا بعدد الأجزاء المأخوذة، والمقام في الأسفل ويخبرنا بعدد الأجزاء المتساوية الكلية.', examplesAr: ['في 3/5 البسط 3 والمقام 5', 'في 2/7 البسط 2 والمقام 7']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 40', questions: [ChoiceQuestion(questionAr: 'في 3/5 ما البسط؟', options: ['3', '5', '8'], correctIndex: 0), ChoiceQuestion(questionAr: 'في 2/7 ما المقام؟', options: ['2', '5', '7'], correctIndex: 2)]),
    ]),
    UnitModel(id: 'unit_41', order: 41, titleAr: 'مقارنة الكسور', ageRangeAr: '10–13 سنة', descriptionAr: 'مقارنة الكسور ذات المقام نفسه أو البسط نفسه.', activities: [
      LessonActivityConfig(titleAr: 'أيهما أكبر؟', explanationAr: 'عند تساوي المقامات، الكسر ذو البسط الأكبر يكون أكبر.', examplesAr: ['3/5 > 2/5', '1/2 > 1/4']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 41', questions: [ChoiceQuestion(questionAr: 'أي كسر أكبر؟', options: ['1/2', '1/4', '1/8'], correctIndex: 0), ChoiceQuestion(questionAr: 'أي كسر أكبر؟', options: ['2/5', '4/5', '1/5'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_42', order: 42, titleAr: 'جمع وطرح الكسور', ageRangeAr: '11–14 سنة', descriptionAr: 'جمع وطرح الكسور ذات المقامات المتساوية.', activities: [
      LessonActivityConfig(titleAr: 'نجمع الأجزاء', explanationAr: 'عند تساوي المقامات نجمع أو نطرح البسط ونبقي المقام نفسه ثم نبسط إن أمكن.', examplesAr: ['1/4 + 1/4 = 2/4 = 1/2', '3/5 − 1/5 = 2/5']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 42', questions: [ChoiceQuestion(questionAr: '1/4 + 1/4 = ؟', options: ['1/2', '1/4', '2/8'], correctIndex: 0), ChoiceQuestion(questionAr: '3/5 − 1/5 = ؟', options: ['1/5', '2/5', '3/5'], correctIndex: 1), ChoiceQuestion(questionAr: '2/6 + 1/6 = ؟', options: ['3/6', '2/6', '1/6'], correctIndex: 0)]),
    ]),
    UnitModel(id: 'unit_43', order: 43, titleAr: 'الأعداد العشرية', ageRangeAr: '11–14 سنة', descriptionAr: 'فهم الأعشار والمئات وقراءة الأعداد العشرية.', activities: [
      LessonActivityConfig(titleAr: 'الأعشار والمئات', explanationAr: 'العدد العشري يصف أجزاء من الواحد باستخدام الفاصلة العشرية.', examplesAr: ['0.5 = 5 أعشار', '0.25 = 25 جزءًا من مئة']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 43', questions: [ChoiceQuestion(questionAr: '0.5 يساوي؟', options: ['5 أعشار', '5 وحدات', '50 عشرات'], correctIndex: 0), ChoiceQuestion(questionAr: '0.25 يساوي كم جزءًا من مئة؟', options: ['2', '25', '250'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_44', order: 44, titleAr: 'عمليات الأعداد العشرية', ageRangeAr: '11–14 سنة', descriptionAr: 'جمع وطرح الأعداد العشرية مع محاذاة الفاصلة.', activities: [
      LessonActivityConfig(titleAr: 'نجمع الأعداد العشرية', explanationAr: 'نرتب الفواصل تحت بعضها ثم نجري العملية كما في الأعداد الصحيحة.', examplesAr: ['1.5 + 2.5 = 4', '5.75 − 2.25 = 3.5']),
      ArithmeticActivityConfig(operation: '+', questions: [ArithmeticQuestion(questionAr: '1.5 + 2.5 = ؟', correctAnswer: 4), ArithmeticQuestion(questionAr: '2.75 + 1.25 = ؟', correctAnswer: 4)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 44', questions: [ChoiceQuestion(questionAr: '1.5 + 2.5 = ؟', options: ['3', '4', '5'], correctIndex: 1), ChoiceQuestion(questionAr: '5.75 − 2.25 = ؟', options: ['2.5', '3.5', '4.5'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_45', order: 45, titleAr: 'النسبة المئوية', ageRangeAr: '12–15 سنة', descriptionAr: 'فهم النسبة المئوية كجزء من مئة وحساب النسب البسيطة.', activities: [
      LessonActivityConfig(titleAr: 'ما هي النسبة المئوية؟', explanationAr: 'النسبة المئوية تعبّر عن عدد من كل 100.', examplesAr: ['50% = 50 من 100', '25% = 25 من 100']),
      ArithmeticActivityConfig(operation: '%', questions: [ArithmeticQuestion(questionAr: '25% من 100 = ؟', correctAnswer: 25), ArithmeticQuestion(questionAr: '50% من 80 = ؟', correctAnswer: 40)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 45', questions: [ChoiceQuestion(questionAr: '50% تساوي؟', options: ['نصف', 'ثلث', 'ربع'], correctIndex: 0), ChoiceQuestion(questionAr: '25% من 100 تساوي؟', options: ['20', '25', '50'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_46', order: 46, titleAr: 'النسبة والتناسب', ageRangeAr: '12–15 سنة', descriptionAr: 'فهم النسب والتناسب وحل تناسبات بسيطة.', activities: [
      LessonActivityConfig(titleAr: 'التناسب', explanationAr: 'إذا حافظت كميتان على العلاقة نفسها نقول إنهما متناسبتان.', examplesAr: ['2:4 = 1:2', '3:6 = 1:2']),
      ArithmeticActivityConfig(operation: '×', questions: [ArithmeticQuestion(questionAr: 'إذا كان 2 دفاتر بـ 10، فثمن 4 دفاتر = ؟', correctAnswer: 20)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 46', questions: [ChoiceQuestion(questionAr: '2:4 تساوي أي نسبة؟', options: ['1:2', '2:3', '3:4'], correctIndex: 0), ChoiceQuestion(questionAr: 'إذا كان 2 دفتر بـ 10 دراهم، فكم 4 دفاتر؟', options: ['15', '20', '25'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_47', order: 47, titleAr: 'المتغيرات والتعبيرات الجبرية', ageRangeAr: '13–16 سنة', descriptionAr: 'فهم المتغير وكتابة التعبيرات الجبرية البسيطة.', activities: [
      LessonActivityConfig(titleAr: 'ما هو المتغير؟', explanationAr: 'المتغير حرف يمثل عددًا يمكن أن تتغير قيمته.', examplesAr: ['x + 3', '2x']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 47', questions: [ChoiceQuestion(questionAr: 'في x + 3، ما المتغير؟', options: ['x', '3', '+'], correctIndex: 0), ChoiceQuestion(questionAr: 'ما التعبير الذي يعني ضعف x؟', options: ['x + 2', '2x', 'x − 2'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_48', order: 48, titleAr: 'تبسيط التعبيرات', ageRangeAr: '13–16 سنة', descriptionAr: 'جمع الحدود المتشابهة وتبسيط التعبيرات.', activities: [
      LessonActivityConfig(titleAr: 'نجمع الحدود المتشابهة', explanationAr: 'نجمع معاملات الحدود التي لها المتغير نفسه ونبقي المتغير.', examplesAr: ['2x + 3x = 5x', '4a + a = 5a']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 48', questions: [ChoiceQuestion(questionAr: '2x + 3x = ؟', options: ['5x', '6x', '5'], correctIndex: 0), ChoiceQuestion(questionAr: '4a + a = ؟', options: ['4a', '5a', 'a'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_49', order: 49, titleAr: 'المعادلات البسيطة', ageRangeAr: '13–16 سنة', descriptionAr: 'حل معادلات من خطوة واحدة باستخدام العملية العكسية.', activities: [
      LessonActivityConfig(titleAr: 'نبحث عن المجهول', explanationAr: 'نستخدم العملية العكسية لعزل المتغير والتحقق من الحل.', examplesAr: ['x + 3 = 7 إذن x = 4', 'x − 5 = 9 إذن x = 14']),
      ArithmeticActivityConfig(operation: '=', questions: [ArithmeticQuestion(questionAr: 'إذا كان x + 5 = 12، فما قيمة x؟', correctAnswer: 7), ArithmeticQuestion(questionAr: 'إذا كان x − 4 = 9، فما قيمة x؟', correctAnswer: 13)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 49', questions: [ChoiceQuestion(questionAr: 'x + 3 = 7، ما قيمة x؟', options: ['3', '4', '10'], correctIndex: 1), ChoiceQuestion(questionAr: 'x − 5 = 9، ما قيمة x؟', options: ['4', '14', '15'], correctIndex: 1)]),
    ]),
    UnitModel(id: 'unit_50', order: 50, titleAr: 'المعادلات ذات الخطوتين', ageRangeAr: '14–16 سنة', descriptionAr: 'حل معادلات تحتاج إلى عمليتين عكسيتين.', activities: [
      LessonActivityConfig(titleAr: 'خطوتان للحل', explanationAr: 'نعكس الجمع أو الطرح أولًا ثم الضرب أو القسمة، مع الحفاظ على تساوي الطرفين.', examplesAr: ['2x + 3 = 11 إذن x = 4', '3x − 6 = 12 إذن x = 6']),
      ArithmeticActivityConfig(operation: '=', questions: [ArithmeticQuestion(questionAr: '2x + 3 = 11، x = ؟', correctAnswer: 4), ArithmeticQuestion(questionAr: '3x − 6 = 12، x = ؟', correctAnswer: 6)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 50', questions: [ChoiceQuestion(questionAr: '2x + 3 = 11، قيمة x؟', options: ['3', '4', '5'], correctIndex: 1), ChoiceQuestion(questionAr: '3x − 6 = 12، قيمة x؟', options: ['4', '5', '6'], correctIndex: 2)]),
    ]),
    UnitModel(id: 'unit_51', order: 51, titleAr: 'المتباينات والتناسب', ageRangeAr: '14–16 سنة', descriptionAr: 'فهم رموز المتباينات وحل متباينات بسيطة.', activities: [
      LessonActivityConfig(titleAr: 'أكبر وأصغر', explanationAr: 'نستخدم > و< و≥ و≤ لمقارنة القيم، ونختبر الحلول في المتباينة.', examplesAr: ['x > 5 يقبل 8', 'x ≤ 4 يقبل 4']),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 51', questions: [ChoiceQuestion(questionAr: 'أي قيمة تحقق x > 5؟', options: ['3', '5', '8'], correctIndex: 2), ChoiceQuestion(questionAr: 'أي قيمة تحقق x ≤ 4؟', options: ['5', '6', '4'], correctIndex: 2)]),
    ]),
    UnitModel(id: 'unit_52', order: 52, titleAr: 'المسائل الرياضية الشاملة', ageRangeAr: '14–16 سنة', descriptionAr: 'تطبيق العمليات والكسور والعشريات والنسب والجبر في مسائل متعددة الخطوات.', activities: [
      LessonActivityConfig(titleAr: 'اختبار شامل', explanationAr: 'نختار الخطة المناسبة، نحسب بدقة، ثم نتحقق من معقولية الإجابة.', examplesAr: ['9 × 8 = 72', 'x + 5 = 12 إذن x = 7']),
      ArithmeticActivityConfig(operation: '×', questions: [ArithmeticQuestion(questionAr: '9 × 8 = ؟', correctAnswer: 72), ArithmeticQuestion(questionAr: '125 × 4 = ؟', correctAnswer: 500)]),
      AssessmentActivityConfig(titleAr: 'كوييز الوحدة 52', questions: [ChoiceQuestion(questionAr: '9 × 8 = ؟', options: ['64', '72', '81'], correctIndex: 1), ChoiceQuestion(questionAr: 'إذا كان x + 5 = 12 فما x؟', options: ['5', '7', '17'], correctIndex: 1)]),
    ]),
  ];

  static UnitModel byId(String id) =>
      units.firstWhere((u) => u.id == id, orElse: () => units.first);
}

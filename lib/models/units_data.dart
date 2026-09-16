import 'unit_model.dart';

/// المنهج الرئيسي لأرقامي: من تأسيس مفهوم العدد في عمر 3 سنوات
/// إلى أساسيات الجبر والعمليات في عمر المراهقة.
class UnitsData {
  static final List<UnitModel> units = [
    const UnitModel(id: 'unit_01', order: 1, titleAr: 'الصفر والعدد 1', ageRangeAr: '3–4 سنوات', descriptionAr: 'فهم معنى لا شيء والتعرف على 0 و1 وكتابتهما.', activities: [
      LessonActivityConfig(titleAr: 'ما هو الصفر؟', explanationAr: 'الصفر يعني أنه لا يوجد شيء. والعدد 1 يعني شيئًا واحدًا.', examplesAr: ['0 تفاحات', '1 تفاحة']),
      TraceActivityConfig(0), TraceActivityConfig(1),
      MatchingActivityConfig([
        MatchPairSpec(id: '0', leftType: MatchContentType.number, leftValue: 0, rightType: MatchContentType.quantity, rightValue: 0),
        MatchPairSpec(id: '1', leftType: MatchContentType.number, leftValue: 1, rightType: MatchContentType.quantity, rightValue: 1),
      ]),
    ]),
    const UnitModel(id: 'unit_02', order: 2, titleAr: 'العد 0–3', ageRangeAr: '3–4 سنوات', activities: [
      LessonActivityConfig(titleAr: 'نعد معًا', explanationAr: 'نرتب الأعداد من الأصغر إلى الأكبر.', examplesAr: ['0، 1، 2، 3']),
      TraceActivityConfig(2), TraceActivityConfig(3), DragCountActivityConfig(3),
    ]),
    const UnitModel(id: 'unit_03', order: 3, titleAr: 'الأعداد 4 و5', ageRangeAr: '3–5 سنوات', activities: [TraceActivityConfig(4), TraceActivityConfig(5), DragCountActivityConfig(5)]),
    const UnitModel(id: 'unit_04', order: 4, titleAr: 'الأعداد 6 و7', ageRangeAr: '4–5 سنوات', activities: [TraceActivityConfig(6), TraceActivityConfig(7), DragCountActivityConfig(7)]),
    const UnitModel(id: 'unit_05', order: 5, titleAr: 'الأعداد 8 و9', ageRangeAr: '4–5 سنوات', activities: [TraceActivityConfig(8), TraceActivityConfig(9), DragCountActivityConfig(9)]),
    const UnitModel(id: 'unit_06', order: 6, titleAr: 'العدد 10 ومفهوم العشرة', ageRangeAr: '4–6 سنوات', activities: [
      LessonActivityConfig(titleAr: 'ما هي العشرة؟', explanationAr: 'عندما نجمع عشرة أشياء نحصل على مجموعة من عشرة.', examplesAr: ['10 أصابع', '10 ألعاب']),
      TraceActivityConfig(1), TraceActivityConfig(0), DragCountActivityConfig(10),
    ]),
    UnitModel(id: 'unit_07', order: 7, titleAr: 'مراجعة الأعداد 0–10', ageRangeAr: '4–6 سنوات', activities: [
      MatchingActivityConfig([
        MatchPairSpec(id: '0', leftType: MatchContentType.number, leftValue: 0, rightType: MatchContentType.quantity, rightValue: 0),
        MatchPairSpec(id: '2', leftType: MatchContentType.number, leftValue: 2, rightType: MatchContentType.quantity, rightValue: 2),
        MatchPairSpec(id: '4', leftType: MatchContentType.number, leftValue: 4, rightType: MatchContentType.quantity, rightValue: 4),
        MatchPairSpec(id: '6', leftType: MatchContentType.number, leftValue: 6, rightType: MatchContentType.quantity, rightValue: 6),
        MatchPairSpec(id: '8', leftType: MatchContentType.number, leftValue: 8, rightType: MatchContentType.quantity, rightValue: 8),
        MatchPairSpec(id: '10', leftType: MatchContentType.number, leftValue: 10, rightType: MatchContentType.quantity, rightValue: 10),
      ]),
      const ComparisonActivityConfig(leftCount: 3, rightCount: 7, question: ComparisonQuestionType.fewer),
      const ComparisonActivityConfig(leftCount: 9, rightCount: 5, question: ComparisonQuestionType.more),
      const AssessmentActivityConfig(titleAr: 'اختبار الأعداد 0–10', questions: [
        ChoiceQuestion(questionAr: 'ما العدد الذي يأتي بعد 6؟', options: ['5', '7', '9'], correctIndex: 1),
        ChoiceQuestion(questionAr: 'أي عدد أكبر؟', options: ['3', '8', '2'], correctIndex: 1),
      ]),
    ]),

    const UnitModel(id: 'unit_08', order: 8, titleAr: 'الآحاد والعشرات', ageRangeAr: '5–7 سنوات', activities: [LessonActivityConfig(titleAr: 'القيمة المكانية', explanationAr: 'كل عدد من خانتين يتكون من آحاد وعشرات.', examplesAr: ['24 = عشراتان و4 آحاد', '50 = 5 عشرات و0 آحاد'])]),
    const UnitModel(id: 'unit_09', order: 9, titleAr: 'الأعداد 11–20', ageRangeAr: '5–7 سنوات', activities: [LessonActivityConfig(titleAr: 'من 11 إلى 20', explanationAr: 'بعد عشرة نبدأ ببناء الأعداد الجديدة من عشرات وآحاد.', examplesAr: ['11 = 10 + 1', '20 = 2 عشرات'])]),
    const UnitModel(id: 'unit_10', order: 10, titleAr: 'الأعداد 21–50', ageRangeAr: '5–7 سنوات', activities: [LessonActivityConfig(titleAr: 'نبني الأعداد', explanationAr: 'نقرأ العدد ونفككه إلى عشرات وآحاد.', examplesAr: ['34 = 30 + 4', '47 = 40 + 7'])]),
    const UnitModel(id: 'unit_11', order: 11, titleAr: 'الأعداد 51–99', ageRangeAr: '5–7 سنوات', activities: [LessonActivityConfig(titleAr: 'حتى 99', explanationAr: 'نتدرب على قراءة وكتابة جميع الأعداد ذات الخانتين.', examplesAr: ['58 = 50 + 8', '99 = 90 + 9'])]),
    const UnitModel(id: 'unit_12', order: 12, titleAr: 'ترتيب ومقارنة الأعداد حتى 100', ageRangeAr: '6–8 سنوات', activities: [MultipleChoiceActivityConfig([
      ChoiceQuestion(questionAr: 'أي عدد أكبر؟', options: ['36', '63', '26'], correctIndex: 1),
      ChoiceQuestion(questionAr: 'ما العدد الذي يأتي بعد 79؟', options: ['78', '80', '89'], correctIndex: 1),
    ])]),
    const UnitModel(id: 'unit_13', order: 13, titleAr: 'مراجعة الأعداد حتى 100', ageRangeAr: '6–8 سنوات', activities: [ReviewActivityConfig(titleAr: 'مراجعة العشرات', questions: [ChoiceQuestion(questionAr: 'كم عشرة في 80؟', options: ['6', '8', '10'], correctIndex: 1)])]),
    const UnitModel(id: 'unit_14', order: 14, titleAr: 'مفهوم المئات', ageRangeAr: '7–9 سنوات', activities: [LessonActivityConfig(titleAr: 'المئات', explanationAr: 'مئة وحدة تساوي عشرة عشرات.', examplesAr: ['100 = مئة', '200 = مئتان'])]),
    const UnitModel(id: 'unit_15', order: 15, titleAr: 'الأعداد حتى 500', ageRangeAr: '7–9 سنوات', activities: [LessonActivityConfig(titleAr: 'نبني المئات', explanationAr: 'نتعلم قراءة وكتابة الأعداد من 100 إلى 500.', examplesAr: ['125 = 100 + 20 + 5'])]),
    const UnitModel(id: 'unit_16', order: 16, titleAr: 'الأعداد حتى 999', ageRangeAr: '7–9 سنوات', activities: [LessonActivityConfig(titleAr: 'ثلاث خانات', explanationAr: 'كل عدد من ثلاث خانات يتكون من مئات وعشرات وآحاد.', examplesAr: ['348 = 300 + 40 + 8'])]),
  ];

  static UnitModel byId(String id) => units.firstWhere((u) => u.id == id, orElse: () => units.first);
}

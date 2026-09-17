import 'unit_model.dart';

/// مواصفات التعلم العميق للوحدة. هذه الطبقة تصف الهدف والمهارات والتحدي
/// النهائي دون ربط المنهج بواجهة بعينها.
class CurriculumSpec {
  final String learningGoalAr;
  final List<String> objectivesAr;
  final List<String> skillsAr;
  final List<String> activityPlanAr;
  final String finalChallengeAr;
  final int estimatedMinutes;
  final double masteryTarget;

  const CurriculumSpec({
    required this.learningGoalAr,
    required this.objectivesAr,
    required this.skillsAr,
    required this.activityPlanAr,
    required this.finalChallengeAr,
    this.estimatedMinutes = 8,
    this.masteryTarget = .8,
  });
}

/// الخطة التعليمية التفصيلية للوحدات الـ52.
/// نوع النشاط المطلوب في المسار التعليمي. تعريف برمجي مستقل عن النص العربي.
enum CurriculumActivityKind {
  lesson,
  trace,
  dragCount,
  matching,
  comparison,
  sceneExplore,
  quiz,
  review,
  arithmetic,
  wordProblem,
}

class CurriculumActivityPlanner {
  CurriculumActivityPlanner._();

  static List<ActivityConfig> plan(UnitModel unit) {
    final source = unit.sourceActivities;
    final kinds = CurriculumSpecs.activityKindsForUnit(unit);
    final used = <int>{};
    final result = <ActivityConfig>[];

    for (final kind in kinds) {
      for (var i = 0; i < source.length; i++) {
        if (used.contains(i) || !_matches(source[i], kind)) continue;
        result.add(source[i]);
        used.add(i);
        break;
      }
    }

    for (var i = 0; i < source.length; i++) {
      if (used.contains(i)) continue;
      if (source[i] is AssessmentActivityConfig) {
        result.add(source[i]);
        used.add(i);
      }
    }

    for (var i = 0; i < source.length; i++) {
      if (!used.contains(i)) result.add(source[i]);
    }

    return List.unmodifiable(result);
  }

  static bool _matches(ActivityConfig config, CurriculumActivityKind kind) {
    switch (kind) {
      case CurriculumActivityKind.lesson:
        return config is LessonActivityConfig;
      case CurriculumActivityKind.trace:
        return config is TraceActivityConfig;
      case CurriculumActivityKind.dragCount:
        return config is DragCountActivityConfig;
      case CurriculumActivityKind.matching:
        return config is MatchingActivityConfig;
      case CurriculumActivityKind.comparison:
        return config is ComparisonActivityConfig;
      case CurriculumActivityKind.sceneExplore:
        return config is SceneExploreActivityConfig;
      case CurriculumActivityKind.quiz:
        return config is MultipleChoiceActivityConfig;
      case CurriculumActivityKind.review:
        return config is ReviewActivityConfig;
      case CurriculumActivityKind.arithmetic:
        return config is ArithmeticActivityConfig;
      case CurriculumActivityKind.wordProblem:
        return config is WordProblemActivityConfig;
    }
  }
}


class CurriculumSpecs {
  CurriculumSpecs._();

  static CurriculumSpec forUnit(UnitModel unit) => _specs[unit.order - 1];

  static List<CurriculumActivityKind> activityKindsForUnit(UnitModel unit) {
    final n = unit.order;
    if (n <= 6 || (n >= 8 && n <= 12)) {
      return const [
        CurriculumActivityKind.lesson,
        CurriculumActivityKind.trace,
        CurriculumActivityKind.dragCount,
        CurriculumActivityKind.matching,
        CurriculumActivityKind.quiz,
      ];
    }
    if (n == 7 || n == 13) {
      return const [
        CurriculumActivityKind.lesson,
        CurriculumActivityKind.review,
        CurriculumActivityKind.matching,
        CurriculumActivityKind.comparison,
        CurriculumActivityKind.quiz,
      ];
    }
    if (n >= 14 && n <= 34) {
      return const [
        CurriculumActivityKind.lesson,
        CurriculumActivityKind.matching,
        CurriculumActivityKind.comparison,
        CurriculumActivityKind.quiz,
      ];
    }
    if (n >= 35 && n <= 40) {
      return const [
        CurriculumActivityKind.lesson,
        CurriculumActivityKind.arithmetic,
        CurriculumActivityKind.wordProblem,
        CurriculumActivityKind.quiz,
      ];
    }
    if (n >= 41 && n <= 46) {
      return const [
        CurriculumActivityKind.lesson,
        CurriculumActivityKind.arithmetic,
        CurriculumActivityKind.matching,
        CurriculumActivityKind.quiz,
      ];
    }
    if (n == 47 || n == 48) {
      return const [
        CurriculumActivityKind.lesson,
        CurriculumActivityKind.quiz,
        CurriculumActivityKind.quiz,
        CurriculumActivityKind.review,
      ];
    }
    if (n == 49) {
      return const [
        CurriculumActivityKind.lesson,
        CurriculumActivityKind.quiz,
        CurriculumActivityKind.arithmetic,
        CurriculumActivityKind.review,
      ];
    }
    if (n == 50 || n == 51) {
      return const [
        CurriculumActivityKind.lesson,
        CurriculumActivityKind.arithmetic,
        CurriculumActivityKind.quiz,
        CurriculumActivityKind.review,
      ];
    }
    return const [
      CurriculumActivityKind.lesson,
      CurriculumActivityKind.quiz,
      CurriculumActivityKind.arithmetic,
      CurriculumActivityKind.review,
    ];
  }



  static const List<CurriculumSpec> _specs = [
    CurriculumSpec(learningGoalAr:'فهم الصفر', objectivesAr:['تمييز 0 كعدم وجود كمية','ربط الرمز بالكمية'], skillsAr:['التعرف البصري','الكمية'], activityPlanAr:['درس بصري','اسحب وعدّ','مطابقة الرمز بالكمية','تتبع 0','تحدي الصفر'], finalChallengeAr:'أكمل حديقة فارغة ثم اختر 0 الصحيح', estimatedMinutes:7),
    CurriculumSpec(learningGoalAr:'فهم الواحد', objectivesAr:['تمييز 1','ربط الواحد بشيء واحد'], skillsAr:['التعرف','العد واحداً'], activityPlanAr:['درس بصري','تتبع 1','اسحب وعدّ','مطابقة','تحدي الواحد'], finalChallengeAr:'ابحث عن مجموعة فيها شيء واحد', estimatedMinutes:7),
    CurriculumSpec(learningGoalAr:'فهم العدد 2', objectivesAr:['عد عنصرين','ربط 2 بالكمية'], skillsAr:['العد','المطابقة'], activityPlanAr:['درس','تتبع 2','اسحب وعدّ','مطابقة','تحدي 2'], finalChallengeAr:'اجمع شيئين في السلة دون زيادة', estimatedMinutes:7),
    CurriculumSpec(learningGoalAr:'فهم العدد 3', objectivesAr:['عد حتى 3','تمييز 3 بصرياً'], skillsAr:['العد المتسلسل','المطابقة'], activityPlanAr:['درس','تتبع 3','اسحب وعدّ','مطابقة','تحدي 3'], finalChallengeAr:'ابنِ مجموعة من 3 عناصر', estimatedMinutes:7),
    CurriculumSpec(learningGoalAr:'فهم العدد 4', objectivesAr:['عد حتى 4','ربط الرمز بالكمية'], skillsAr:['العد','التعرف الرقمي'], activityPlanAr:['درس','تتبع 4','اسحب وعدّ','مقارنة','تحدي 4'], finalChallengeAr:'أكمل 4 عناصر في الحديقة', estimatedMinutes:7),
    CurriculumSpec(learningGoalAr:'فهم العدد 5', objectivesAr:['عد حتى 5','تمييز مجموعات من 5'], skillsAr:['العد','الإدراك الكمي'], activityPlanAr:['درس','تتبع 5','اسحب وعدّ','مطابقة','تحدي 5'], finalChallengeAr:'اجمع 5 نجوم بالضبط', estimatedMinutes:7),
    CurriculumSpec(learningGoalAr:'إتقان 0–5', objectivesAr:['تمييز الأعداد 0–5','ترتيبها','مقارنة كمياتها'], skillsAr:['الترتيب','المقارنة','الاستدعاء'], activityPlanAr:['مراجعة','مطابقة','مقارنة','عدّ','تحدي مختلط'], finalChallengeAr:'أكمل مسار 0–5 بالترتيب الصحيح', estimatedMinutes:8),
    CurriculumSpec(learningGoalAr:'فهم العدد 6', objectivesAr:['العد إلى 6','فهم 5+1'], skillsAr:['العد','الإضافة البسيطة'], activityPlanAr:['درس','تتبع 6','اسحب وعدّ','اختيار','تحدي 6'], finalChallengeAr:'أضف عنصراً واحداً إلى خمسة', estimatedMinutes:8),
    CurriculumSpec(learningGoalAr:'فهم العدد 7', objectivesAr:['العد إلى 7','مقارنة 7 بأعداد أصغر'], skillsAr:['العد','المقارنة'], activityPlanAr:['درس','تتبع 7','عدّ','مقارنة','تحدي 7'], finalChallengeAr:'كوّن مجموعة من 7 ثم قارنها بمجموعة أصغر', estimatedMinutes:8),
    CurriculumSpec(learningGoalAr:'فهم العدد 8', objectivesAr:['العد إلى 8','ربط 8 بالكمية'], skillsAr:['العد','المقارنة'], activityPlanAr:['درس','تتبع 8','عدّ','مطابقة','تحدي 8'], finalChallengeAr:'اجمع 8 عناصر دون فقدان العد', estimatedMinutes:8),
    CurriculumSpec(learningGoalAr:'فهم العدد 9', objectivesAr:['العد إلى 9','اكتشاف قرب 10'], skillsAr:['العد','التسلسل'], activityPlanAr:['درس','تتبع 9','عدّ','مقارنة','تحدي 9'], finalChallengeAr:'أكمل مجموعة 9 ثم حدد العدد التالي', estimatedMinutes:8),
    CurriculumSpec(learningGoalAr:'بناء العدد 10', objectivesAr:['عد عشر وحدات','فهم 10 كمجموعة كاملة'], skillsAr:['العد','التجميع'], activityPlanAr:['درس','بناء مجموعة','اسحب وعدّ','مطابقة','تحدي 10'], finalChallengeAr:'كوّن عشرة عناصر في مجموعة واحدة', estimatedMinutes:9),
    CurriculumSpec(learningGoalAr:'إتقان 0–10', objectivesAr:['قراءة 0–10','ترتيبها','مقارنة الكميات'], skillsAr:['الترتيب','المقارنة','العد'], activityPlanAr:['مراجعة','مطابقة','مقارنة','عدّ','تحدي الاستعداد'], finalChallengeAr:'أنهِ مسار الأعداد من 0 إلى 10 دون خطأ', estimatedMinutes:9),
    CurriculumSpec(learningGoalAr:'قيمة الآحاد والعشرات', objectivesAr:['تمييز الخانتين','بناء عدد من عشرات وآحاد'], skillsAr:['القيمة المكانية','البناء'], activityPlanAr:['درس بالمكعبات','بناء عدد','مطابقة','مقارنة','تحدي القيمة المكانية'], finalChallengeAr:'ابنِ عدداً من رقمين ثم فسّره', estimatedMinutes:10),
    CurriculumSpec(learningGoalAr:'تفكيك 11–20', objectivesAr:['تفكيك العدد إلى 10 وآحاد','بناء العدد من أجزائه'], skillsAr:['التحليل','القيمة المكانية'], activityPlanAr:['درس','بناء بالعشرات','مطابقة الأجزاء','مقارنة','تحدي البناء'], finalChallengeAr:'حوّل 10 وآحاد إلى العدد المطلوب', estimatedMinutes:10),
    CurriculumSpec(learningGoalAr:'تفكيك 21–30', objectivesAr:['قراءة العشرات والآحاد','تمثيل العدد'], skillsAr:['القيمة المكانية','التمثيل'], activityPlanAr:['درس','بناء','مطابقة','ترتيب','تحدي'], finalChallengeAr:'ابنِ ثلاثة أعداد ثم رتبها', estimatedMinutes:10),
    CurriculumSpec(learningGoalAr:'الأعداد 31–40', objectivesAr:['بناء أعداد 31–40','تحديد قيمة الآحاد'], skillsAr:['القيمة المكانية','المقارنة'], activityPlanAr:['درس','بناء','مطابقة','مقارنة','تحدي'], finalChallengeAr:'اكتشف العدد من عشراته وآحاده', estimatedMinutes:10),
    CurriculumSpec(learningGoalAr:'الأعداد 41–50', objectivesAr:['بناء أعداد 41–50','قراءة العشرات'], skillsAr:['القيمة المكانية','القراءة'], activityPlanAr:['درس','بناء','مطابقة','ترتيب','تحدي'], finalChallengeAr:'أكمل مدينة الأعداد حتى 50', estimatedMinutes:10),
    CurriculumSpec(learningGoalAr:'الأعداد 51–60', objectivesAr:['بناء أعداد 51–60','تمييز العشرات'], skillsAr:['القيمة المكانية','التسلسل'], activityPlanAr:['درس','بناء','عدّ بالعشرات','مقارنة','تحدي'], finalChallengeAr:'أصلح أعداداً ناقصة بين 51 و60', estimatedMinutes:10),
    CurriculumSpec(learningGoalAr:'الأعداد 61–100', objectivesAr:['قراءة أعداد حتى 100','العد بالعشرات والآحاد'], skillsAr:['القيمة المكانية','الترتيب','المقارنة'], activityPlanAr:['درس','خط أعداد','بناء','ترتيب','تحدي 100'], finalChallengeAr:'أكمل طريقاً يصل إلى 100', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'المئات', objectivesAr:['فهم 100 كمئة','تمييز المئات والعشرات والآحاد'], skillsAr:['القيمة المكانية','التجميع'], activityPlanAr:['درس بالمكعبات','بناء 100','مطابقة','مقارنة','تحدي المئة'], finalChallengeAr:'ابنِ 100 ثم فككه إلى قيم مكانية', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'101–200', objectivesAr:['قراءة أعداد ثلاثية','تفكيك العدد'], skillsAr:['القيمة المكانية','التحليل'], activityPlanAr:['درس','بناء','تفكيك','مقارنة','تحدي'], finalChallengeAr:'اكتشف عدد المدينة من مئات وعشرات وآحاد', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'201–300', objectivesAr:['قراءة 201–300','تحديد قيمة كل خانة'], skillsAr:['القيمة المكانية','القراءة'], activityPlanAr:['درس','بناء','مطابقة','ترتيب','تحدي'], finalChallengeAr:'رتب أعداد المدينة حول 300', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'301–400', objectivesAr:['بناء أعداد 301–400','المقارنة'], skillsAr:['البناء','المقارنة'], activityPlanAr:['درس','بناء','مقارنة','خط أعداد','تحدي'], finalChallengeAr:'ساعد رقّومي على الوصول إلى 400', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'401–500', objectivesAr:['قراءة أعداد 401–500','التفكيك'], skillsAr:['التحليل','القيمة المكانية'], activityPlanAr:['درس','تفكيك','مطابقة','ترتيب','تحدي'], finalChallengeAr:'فكك أعداداً من 401 إلى 500', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'501–600', objectivesAr:['قراءة أعداد 501–600','تحديد المئات'], skillsAr:['القيمة المكانية','التسلسل'], activityPlanAr:['درس','بناء','مقارنة','ترتيب','تحدي'], finalChallengeAr:'ابنِ بوابات المئات حتى 600', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'601–700', objectivesAr:['قراءة أعداد 601–700','تمييز تغير المئات'], skillsAr:['القراءة','القيمة المكانية'], activityPlanAr:['درس','بناء','مطابقة','خط أعداد','تحدي'], finalChallengeAr:'أكمل مسار الأعداد حتى 700', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'701–800', objectivesAr:['قراءة أعداد 701–800','تفكيكها'], skillsAr:['التحليل','البناء'], activityPlanAr:['درس','تفكيك','بناء','مقارنة','تحدي'], finalChallengeAr:'حوّل بطاقات 701–800 إلى أعداد صحيحة', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'801–900', objectivesAr:['قراءة أعداد 801–900','ترتيبها'], skillsAr:['الترتيب','القيمة المكانية'], activityPlanAr:['درس','خط أعداد','ترتيب','مطابقة','تحدي'], finalChallengeAr:'رتب محطات 801–900', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'901–999', objectivesAr:['قراءة 901–999','الاستعداد للألف'], skillsAr:['القيمة المكانية','التسلسل'], activityPlanAr:['درس','بناء','مقارنة','خط أعداد','تحدي 999'], finalChallengeAr:'وصل إلى 999 واكتشف ما يأتي بعده', estimatedMinutes:12),
    CurriculumSpec(learningGoalAr:'الألف', objectivesAr:['فهم 1000','ربط 1000 بعشر مئات'], skillsAr:['التجميع','القيمة المكانية'], activityPlanAr:['درس','تجميع مئات','بناء 1000','مطابقة','تحدي الألف'], finalChallengeAr:'اجمع المئات حتى تفتح بوابة 1000', estimatedMinutes:12),
    CurriculumSpec(learningGoalAr:'الأعداد حتى 1000', objectivesAr:['قراءة أعداد ثلاثية','مقارنتها وترتيبها'], skillsAr:['القراءة','المقارنة','الترتيب'], activityPlanAr:['درس','خط أعداد','ترتيب','مطابقة','تحدي المدينة'], finalChallengeAr:'أكمل ترتيب أعداد عشوائية حتى 1000', estimatedMinutes:12),
    CurriculumSpec(learningGoalAr:'الأعداد حتى 10000', objectivesAr:['فهم الآلاف','قراءة أعداد أربعة أرقام'], skillsAr:['القيمة المكانية','القراءة'], activityPlanAr:['درس','بناء بالآلاف','تفكيك','مقارنة','تحدي المملكة'], finalChallengeAr:'ابنِ عدداً من أربعة أرقام من قيمه', estimatedMinutes:12),
    CurriculumSpec(learningGoalAr:'مراجعة القيمة المكانية', objectivesAr:['دمج الآحاد والعشرات والمئات والآلاف','حل مسائل قيمة مكانية'], skillsAr:['التحليل','البناء','الاستدلال'], activityPlanAr:['درس مراجعة','بناء','تفكيك','مقارنة','تحدي نهائي'], finalChallengeAr:'حل خريطة كنز القيمة المكانية', estimatedMinutes:13),
    CurriculumSpec(learningGoalAr:'الجمع بدون حمل', objectivesAr:['جمع أعداد بسيطة','تمثيل الجمع كمجموعتين'], skillsAr:['الجمع','التمثيل'], activityPlanAr:['درس بصري','دمج مجموعتين','حساب','مسألة واقعية','تحدي الجمع'], finalChallengeAr:'اجمع مجموعتين من عناصر الحديقة', estimatedMinutes:10),
    CurriculumSpec(learningGoalAr:'الجمع مع الحمل', objectivesAr:['فهم إعادة التجميع','حل جمع متعدد الخانات'], skillsAr:['إعادة التجميع','الحساب'], activityPlanAr:['درس بالمكعبات','إعادة تجميع','حساب','مسألة','تحدي'], finalChallengeAr:'أنقذ المتجر بحساب المجموع الصحيح', estimatedMinutes:12),
    CurriculumSpec(learningGoalAr:'الطرح بدون استلاف', objectivesAr:['فهم الطرح كإزالة','حل عمليات طرح بسيطة'], skillsAr:['الطرح','التقدير'], activityPlanAr:['درس بصري','إزالة عناصر','حساب','مسألة','تحدي'], finalChallengeAr:'أزل العناصر المطلوبة وأوجد الباقي', estimatedMinutes:10),
    CurriculumSpec(learningGoalAr:'الطرح مع الاستلاف', objectivesAr:['فهم إعادة التجميع في الطرح','حل طرح متعدد الخانات'], skillsAr:['إعادة التجميع','الحساب'], activityPlanAr:['درس بالمكعبات','إعادة تجميع','حساب','مسألة','تحدي'], finalChallengeAr:'حل لغز الصناديق بإعادة التجميع', estimatedMinutes:12),
    CurriculumSpec(learningGoalAr:'مسائل الجمع والطرح', objectivesAr:['اختيار العملية المناسبة','حل مسألة متعددة الخطوات'], skillsAr:['فهم المسألة','الاستدلال','الحساب'], activityPlanAr:['درس استراتيجية','تحديد العملية','حل','تمثيل','تحدي قصصي'], finalChallengeAr:'أكمل مهمة متجر تتطلب جمعاً وطرحاً', estimatedMinutes:13),
    CurriculumSpec(learningGoalAr:'الجمع والطرح المتكامل', objectivesAr:['اختيار العملية','التحقق من المعقولية','حل مسائل متنوعة'], skillsAr:['المرونة الحسابية','التحقق'], activityPlanAr:['مراجعة','تحدي سريع','مسائل','تطبيق واقعي','مهمة نهائية'], finalChallengeAr:'أنهِ مهمة الجزيرة في عدة خطوات', estimatedMinutes:14),
    CurriculumSpec(learningGoalAr:'مفهوم الضرب', objectivesAr:['فهم الضرب كمجموعات متساوية','ربط المجموعات بالعملية'], skillsAr:['التجميع','التكرار'], activityPlanAr:['درس بالمجموعات','مصفوفات','مطابقة','جمع متكرر','تحدي'], finalChallengeAr:'ابنِ مجموعات متساوية واحسب عدد العناصر', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'جداول الضرب الأساسية', objectivesAr:['إتقان الجداول الأساسية تدريجياً','استخدام أنماط الضرب'], skillsAr:['الاستدعاء','الأنماط'], activityPlanAr:['درس','مصفوفة','بطاقات','لعبة سرعة','تحدي'], finalChallengeAr:'افتح أبواب الكوكب بحل جولات ضرب', estimatedMinutes:13),
    CurriculumSpec(learningGoalAr:'الضرب متعدد الخانات', objectivesAr:['ضرب عدد متعدد الخانات','تنظيم خطوات الحل'], skillsAr:['الخوارزمية','القيمة المكانية'], activityPlanAr:['درس','تفكيك','ضرب مرحلي','تطبيق','تحدي'], finalChallengeAr:'أصلح مصنعاً باستخدام ضرب متعدد الخانات', estimatedMinutes:14),
    CurriculumSpec(learningGoalAr:'مفهوم القسمة', objectivesAr:['فهم التوزيع المتساوي','ربط القسمة بالمجموعات'], skillsAr:['التوزيع','التجميع'], activityPlanAr:['درس بالتوزيع','تجميع','مطابقة','حساب','تحدي'], finalChallengeAr:'وزع العناصر بالتساوي على الشخصيات', estimatedMinutes:11),
    CurriculumSpec(learningGoalAr:'القسمة والباقي', objectivesAr:['تمييز الناتج والباقي','حل قسمة مع باقٍ'], skillsAr:['القسمة','تفسير الباقي'], activityPlanAr:['درس','توزيع','حساب','مسألة','تحدي'], finalChallengeAr:'وزع الموارد واكتشف الباقي', estimatedMinutes:13),
    CurriculumSpec(learningGoalAr:'القسمة المطولة', objectivesAr:['تنظيم خطوات القسمة','التحقق بالضرب'], skillsAr:['الخوارزمية','التحقق'], activityPlanAr:['درس مرحلي','قسمة','تحقق بالضرب','مسألة','تحدي'], finalChallengeAr:'حل مسار القسمة خطوة بخطوة', estimatedMinutes:15),
    CurriculumSpec(learningGoalAr:'العمليات الأربع', objectivesAr:['اختيار العملية المناسبة','حل مسائل مختلطة'], skillsAr:['المرونة الحسابية','الاستدلال'], activityPlanAr:['مراجعة','اختيار العملية','حساب','مسائل','تحدي العمليات'], finalChallengeAr:'أكمل مهمة تتطلب العمليات الأربع', estimatedMinutes:15),
    CurriculumSpec(learningGoalAr:'الكسور كأجزاء من كل', objectivesAr:['فهم البسط والمقام','تمثيل الكسر بصرياً'], skillsAr:['التمثيل الكسري','التقسيم'], activityPlanAr:['درس بصري','تقسيم أشكال','مطابقة','مقارنة','تحدي'], finalChallengeAr:'قسّم لوحة إلى أجزاء واكتب الكسر', estimatedMinutes:12),
    CurriculumSpec(learningGoalAr:'مقارنة وجمع الكسور', objectivesAr:['مقارنة كسور مناسبة','جمع كسور بسيطة'], skillsAr:['المقارنة','الجمع الكسري'], activityPlanAr:['درس','أشرطة كسور','مقارنة','جمع بصري','تحدي'], finalChallengeAr:'أكمل وصفة بجمع الكسور الصحيحة', estimatedMinutes:14),
    CurriculumSpec(learningGoalAr:'الأعداد العشرية', objectivesAr:['فهم الأعشار والمئات','ربط العشري بالكسر'], skillsAr:['القيمة المكانية','التحويل'], activityPlanAr:['درس بالنقود','شبكة عشرية','مطابقة','مقارنة','تحدي'], finalChallengeAr:'اضبط الأسعار العشرية في متجر اللعبة', estimatedMinutes:13),
    CurriculumSpec(learningGoalAr:'عمليات الكسور والعشريات', objectivesAr:['إجراء عمليات مناسبة','التحقق من الناتج'], skillsAr:['الحساب','التحويل','التحقق'], activityPlanAr:['مراجعة','تمثيل','حساب','مسألة','تحدي نهائي'], finalChallengeAr:'حل مهمة المجرة بكسور وأعداد عشرية', estimatedMinutes:15),
    CurriculumSpec(learningGoalAr:'النسبة والتناسب', objectivesAr:['فهم العلاقة بين كميتين','حل تناسبات بسيطة'], skillsAr:['النسبة','التناسب','الاستدلال'], activityPlanAr:['درس بصري','مطابقة نسب','جداول','مسألة واقعية','تحدي'], finalChallengeAr:'اضبط وصفة بنسب مختلفة', estimatedMinutes:15),
    CurriculumSpec(learningGoalAr:'النسبة المئوية', objectivesAr:['فهم معنى النسبة المئوية','حساب نسب بسيطة'], skillsAr:['النسبة المئوية','التحويل'], activityPlanAr:['درس شبكي','تحويل','حساب','تطبيق مالي','تحدي'], finalChallengeAr:'حل خصومات ومهام مئوية في المتجر', estimatedMinutes:15),
    CurriculumSpec(learningGoalAr:'التعبيرات الجبرية', objectivesAr:['فهم المتغير','تبسيط تعبيرات بسيطة'], skillsAr:['الرموز','التعويض','الترتيب'], activityPlanAr:['درس رمزي','مطابقة','تعويض','تبسيط','تحدي'], finalChallengeAr:'اكتشف قيمة المتغير لفتح البوابة', estimatedMinutes:16),
    CurriculumSpec(learningGoalAr:'المعادلات والمتباينات', objectivesAr:['حل معادلات بسيطة','تمييز أكبر وأصغر'], skillsAr:['حل المعادلات','الاستدلال','المقارنة'], activityPlanAr:['درس ميزان','حل خطوة بخطوة','تمثيل','مسألة','تحدي الجبر'], finalChallengeAr:'وازن المعادلات وافتح بوابة مملكة الجبر', estimatedMinutes:17),
  ];

  static void validate() {
    assert(_specs.length == 52);
    assert(_specs.every((s) => s.objectivesAr.length >= 2));
    assert(_specs.every((s) => s.activityPlanAr.length >= 4 && s.activityPlanAr.length <= 6));
  }
}

import 'unit_model.dart';
import 'units_data.dart';

/// إصلاحات منهجية صغيرة تكتشفها مراجعة السلوك الفعلي للمحرك.
/// تبقى منفصلة عن ملف المنهج الأساسي حتى لا نعيد كتابة 52 وحدة كاملة.
void applyDeepCurriculumFixes() {
  // الوحدة 15: كانت المطابقة 14→10 و18→10، أي أن نتيجتين مختلفتين
  // تشتركان في نفس الجواب. نستخدم قيمة الآحاد كهدف تربوي فريد.
  UnitsData.units[14] = UnitModel(
    id: 'unit_15',
    order: 15,
    titleAr: 'بناء وتفكيك الأعداد 11–20',
    ageRangeAr: '5–7 سنوات',
    descriptionAr: 'بناء الأعداد من 11 إلى 20 وتفكيكها إلى عشرة وآحاد.',
    activities: [
      const LessonActivityConfig(
        titleAr: 'نبني عدداً من خانتين',
        explanationAr: 'العدد 14 يتكون من عشرة وأربع وحدات. يمكن تفكيكه إلى 10 + 4.',
        examplesAr: ['14 = 10 + 4', '19 = 10 + 9', '20 = 2 عشرات'],
      ),
      const MatchingActivityConfig([
        MatchPairSpec(
          id: '15a',
          leftType: MatchContentType.number,
          leftValue: 14,
          rightType: MatchContentType.quantity,
          rightValue: 4,
        ),
        MatchPairSpec(
          id: '15b',
          leftType: MatchContentType.number,
          leftValue: 18,
          rightType: MatchContentType.quantity,
          rightValue: 8,
        ),
        MatchPairSpec(
          id: '15c',
          leftType: MatchContentType.number,
          leftValue: 20,
          rightType: MatchContentType.quantity,
          rightValue: 0,
        ),
      ]),
      const ComparisonActivityConfig(
        leftCount: 14,
        rightCount: 18,
        question: ComparisonQuestionType.more,
      ),
      const MultipleChoiceActivityConfig([
        ChoiceQuestion(
          questionAr: '14 = ؟',
          options: ['10 + 4', '1 + 4', '40 + 1'],
          correctIndex: 0,
        ),
        ChoiceQuestion(
          questionAr: '20 فيها كم عشرة؟',
          options: ['1', '2', '20'],
          correctIndex: 1,
        ),
      ]),
      const AssessmentActivityConfig(
        titleAr: 'اختبار الوحدة 15',
        questions: [
          ChoiceQuestion(
            questionAr: '18 = ؟',
            options: ['10 + 8', '1 + 8', '80 + 1'],
            correctIndex: 0,
          ),
          ChoiceQuestion(
            questionAr: '20 فيها كم آحاد؟',
            options: ['0', '2', '20'],
            correctIndex: 0,
          ),
        ],
      ),
    ],
  );

  // الوحدة 41: المطابقة القديمة 3→12 و4→20 و5→15 لا تحمل قاعدة واحدة
  // واضحة للطفل لأن العامل الآخر يتغير. الحساب المباشر يعلّم نفس المفهوم
  // بدون علاقة مطابقة ملتبسة.
  UnitsData.units[40] = UnitModel(
    id: 'unit_41',
    order: 41,
    titleAr: 'مفهوم الضرب: الجمع المتكرر والمجموعات المتساوية',
    ageRangeAr: '9–12 سنة',
    descriptionAr: 'بناء مفهوم الضرب من مجموعات متساوية والجمع المتكرر.',
    activities: [
      const LessonActivityConfig(
        titleAr: 'الضرب مجموعات متساوية',
        explanationAr: 'إذا كانت لدينا 3 مجموعات في كل واحدة 4 عناصر، فهذا يساوي 4 + 4 + 4 ويكتب 3 × 4.',
        examplesAr: ['4 + 4 + 4 = 12', '3 × 4 = 12'],
      ),
      const ArithmeticActivityConfig(
        operation: 'الجمع المتكرر إلى الضرب',
        questions: [
          ArithmeticQuestion(questionAr: '4 + 4 + 4 = ؟', correctAnswer: 12),
          ArithmeticQuestion(questionAr: '5 + 5 + 5 + 5 = ؟', correctAnswer: 20),
          ArithmeticQuestion(questionAr: '3 × 4 = ؟', correctAnswer: 12),
        ],
      ),
      const MultipleChoiceActivityConfig([
        ChoiceQuestion(questionAr: '3 × 4 = ؟', options: ['7', '12', '14'], correctIndex: 1),
        ChoiceQuestion(questionAr: '2 مجموعتان من 5 تساويان؟', options: ['7', '10', '12'], correctIndex: 1),
      ]),
      const AssessmentActivityConfig(
        titleAr: 'اختبار الوحدة 41',
        questions: [
          ChoiceQuestion(questionAr: '4 + 4 + 4 = ؟', options: ['8', '12', '16'], correctIndex: 1),
          ChoiceQuestion(questionAr: '3 × 5 = ؟', options: ['8', '15', '20'], correctIndex: 1),
        ],
      ),
    ],
  );

  // الوحدة 44: 12÷3 و20÷5 و24÷6 كلها تعطي 4، لذلك لا يمكن تمثيلها
  // بمطابقة رقم↔رقم فريدة. نستبدل المطابقة بتدريب حسابي مباشر.
  UnitsData.units[43] = UnitModel(
    id: 'unit_44',
    order: 44,
    titleAr: 'مفهوم القسمة: التوزيع المتساوي وعلاقة الضرب',
    ageRangeAr: '9–12 سنة',
    descriptionAr: 'فهم القسمة كتوزيع متساو وربطها بالضرب.',
    activities: [
      const LessonActivityConfig(
        titleAr: 'نوزع بالتساوي',
        explanationAr: '12 ÷ 3 تعني توزيع 12 على 3 مجموعات متساوية، فيكون في كل مجموعة 4. والضرب العكسي هو 3 × 4 = 12.',
        examplesAr: ['12 ÷ 3 = 4', '20 ÷ 5 = 4', '3 × 4 = 12'],
      ),
      const ArithmeticActivityConfig(
        operation: 'القسمة والتوزيع المتساوي',
        questions: [
          ArithmeticQuestion(questionAr: '12 ÷ 3 = ؟', correctAnswer: 4),
          ArithmeticQuestion(questionAr: '20 ÷ 5 = ؟', correctAnswer: 4),
          ArithmeticQuestion(questionAr: '24 ÷ 6 = ؟', correctAnswer: 4),
          ArithmeticQuestion(questionAr: '3 × 4 = ؟', correctAnswer: 12),
        ],
      ),
      const MultipleChoiceActivityConfig([
        ChoiceQuestion(questionAr: '12 ÷ 3 = ؟', options: ['3', '4', '5'], correctIndex: 1),
        ChoiceQuestion(questionAr: '20 ÷ 5 = ؟', options: ['3', '4', '5'], correctIndex: 1),
      ]),
      const AssessmentActivityConfig(
        titleAr: 'اختبار الوحدة 44',
        questions: [
          ChoiceQuestion(questionAr: '24 ÷ 6 = ؟', options: ['3', '4', '5'], correctIndex: 1),
          ChoiceQuestion(questionAr: '3 × 4 = ؟', options: ['7', '12', '16'], correctIndex: 1),
        ],
      ),
    ],
  );
}

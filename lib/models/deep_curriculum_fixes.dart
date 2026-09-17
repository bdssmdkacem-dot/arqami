import 'unit_model.dart';
import 'units_data.dart';

/// إصلاحات منهجية صغيرة تكتشفها مراجعة السلوك الفعلي للمحرك.
/// تبقى منفصلة عن ملف المنهج الأساسي حتى لا نعيد كتابة 52 وحدة كاملة.
void applyDeepCurriculumFixes() {
  // كانت مطابقة الوحدة 15 تحتوي 14→10 و18→10، أي أن نتيجتين مختلفتين
  // تشتركان في نفس الجواب. هذا يجعل نشاط المطابقة ملتبساً وغير صالح
  // لاختبار تفكيك العدد. نستعمل هنا مطابقة خانة الآحاد بقيم فريدة.
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
}

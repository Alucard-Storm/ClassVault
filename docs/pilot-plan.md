# ClassVault Academic Intelligence: pilot plan (Phase 8)

The pilot answers one question before anyone relies on predictions: **do the
signals hold up on real students, and do they help faculty?** A model that
looks good in training is not enough.

## Scope

| | |
|---|---|
| Duration | One full semester (the "pilot semester"), plus about 2 weeks to import results and evaluate |
| Students | 2–4 sections in one programme, ideally 150+ students, so the criteria below can be judged |
| People | **Data lead** (admin): imports, training, evaluation. **Pilot faculty**: 3–6 faculty teaching the pilot sections. **Reviewer**: someone outside the pilot who signs off the decision |
| Not in scope | Showing any signal to students; automatic actions of any kind |

## Before the pilot (weeks −4 to 0)

1. **Agree the definitions** with pilot faculty and the reviewer:
   - What counts as academic difficulty (`labels-v1` in `ml/feature_spec.json`: a first-attempt fail, SGPA below 6.0, or a drop of 1.0 or more).
   - The pilot criteria (`PilotCriteria` in `lib/features/pilot/engine/pilot_evaluation.dart`).
   - The readiness rules and queue weights (`ReadinessRules`, `QueueWeights`).
   Change them now, not after seeing results.
2. **Import history** for at least two earlier cohorts (History Import). Fix rejected rows at the source and re-import until the rejection rate is under 5%.
3. **Train on real data** (Prediction Models → Export CSV, then `python -m classvault_ml train …`). Only continue if the report says **Recommended for use: yes**, meaning every training check passes, including *Stable across data splits*.
4. **Import and activate** one risk model and one forecast model. Leave test (synthetic) models inactive.
5. **Brief pilot faculty** (30 minutes):
   - Signals are prompts for a conversation, not labels.
   - Use the Attention Queue weekly.
   - Record what you do (Notes & interventions).
   - Say when you disagree with a signal (Why this signal? → Disagree, with a reason).

## During the pilot semester

| When | Who | What |
|---|---|---|
| Week 1 | Data lead | Academic Insights → **Generate Predictions** for each pilot section (predicts the pilot semester) |
| Weekly | Pilot faculty | Work through the **Attention Queue** (Needs review first). Add a note for every student you act on; set a follow-up date if there is one |
| When a signal seems wrong | Pilot faculty | **Disagree** on the prediction with a reason. It stops counting in the queue, and the pilot measures whether you were right |
| Mid-semester | Data lead | Check Pilot Evaluation → *Faculty use* (are signals being followed up?) and *Data quality*. Nudge, don't pressure |
| Throughout | Everyone | Do **not** regenerate predictions mid-semester. The evaluation uses the prediction faculty actually saw |

## After the semester

1. Import the pilot semester's results (History Import).
2. Open **Pilot Evaluation** (admin), with test models switched **off**, and **Export Report**.
3. Run the faculty survey below.
4. Hold the decision meeting (data lead, pilot faculty, reviewer), using the report, the survey, and the lists of missed students and false alarms in the app.

## What is measured

Everything below is in **Admin → Pilot Evaluation** and in the exported report. The report contains no student names.

| Plan requirement | Where |
|---|---|
| Precision / recall | Academic risk: precision and recall of "elevated" |
| Calibration | Calibration error; predicted vs observed rates by band |
| False positives / false negatives | Counts, plus named lists in the app (each links to its explanation) |
| Stability across batches | By-section tables; the *Stable across sections* check. In training, cross-validation across student groups |
| Usefulness to faculty | Faculty use: reviews, disagreement rate, whether faculty judgement matched outcomes, elevated signals followed up within 14 days, follow-ups done or overdue. Plus the survey |
| Data-quality failures | Rows rejected and warnings per import, inputs most often missing at prediction time, students with no history |

## Success criteria

The pilot passes when every check in Pilot Evaluation passes, which gives the verdict *"continue the pilot with faculty oversight"*. The proposed thresholds:

| Check | Threshold |
|---|---|
| Enough outcomes to judge | ≥ 30 predictions with outcomes and ≥ 10 students with difficulty |
| Precision of "elevated" | ≥ 50% |
| Recall of "elevated" | ≥ 60% |
| Calibration | Error ≤ 10% |
| Bands are meaningful | Observed difficulty rises from low to moderate to elevated |
| Stable across sections | Recall in each section within 20 points of the overall rate |
| SGPA range coverage | Within ±10 points of the model's promised level (80%) |
| Forecast beats last semester's SGPA | Lower average error than repeating the previous SGPA |
| Faculty agree with signals | Disagreement ≤ 30% (after ≥ 10 reviews) |
| Data quality | ≤ 5% of imported rows rejected; previous SGPA missing for ≤ 20% of predictions |

The survey should show that most pilot faculty found the queue worth their time.

## Faculty survey (end of pilot)

1. How often did you use the Attention Queue? (never / monthly / fortnightly / weekly)
2. The queue pointed me to students I would not otherwise have noticed. (1–5)
3. The "Why this signal?" explanations were understandable. (1–5)
4. The signals were fair to the students concerned. (1–5)
5. Describe a case where a signal was wrong. What was the model missing?
6. What would stop you using this next semester?
7. Should we continue? (yes / yes, with changes / no)

## Decision

| Outcome | When | Next step |
|---|---|---|
| **Continue** | All checks pass and the survey is broadly positive | Extend to more sections; retrain each semester with the new outcomes; repeat this evaluation each semester |
| **Adjust** | Checks are insufficient, or specific failures have clear causes (a data gap, a threshold, one section) | Fix, retrain, and run a second pilot semester |
| **Stop** | Precision, calibration or section stability fail with no clear fix, or faculty find it unhelpful or unfair | Deactivate the models. Analytics (Phase 3) and notes (Phase 7) keep working without them |

## Safeguards (throughout)

- Students never see signals or predictions (enforced by the app's route guard).
- Predictions are decision support. Nothing happens automatically, and a faculty disagreement overrides the model in the queue.
- Test models trained on synthetic data are excluded from the evaluation by default and labelled everywhere.
- Exports are pseudonymous (training CSV) or aggregate-only (pilot report).
- **Stop immediately** if a signal is shown to a student, or used for a high-impact decision (grading, discipline, admissions) instead of support.

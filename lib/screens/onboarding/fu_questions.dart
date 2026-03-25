import 'package:flutter/material.dart';
import 'fu_question_model.dart';

final List<FuQuestion> fuQuestions = [
  FuQuestion(
    key: "name",
    question:
    "Alright superstar — what name should I shout when I send you reminders? 😄",
    type: InputType.text,
  ),
  FuQuestion(
    key: "age",
    question:
    "Quick curiosity check… how many candles were on your last cake? 🎂",
    type: InputType.number,
  ),
  FuQuestion(
    key: "location",
    question:
    "If I mailed you a virtual hug right now… which city would it land in? 🌍",
    type: InputType.text,
  ),
  FuQuestion(
    key: "goal",
    question:
    "So tell me… what made you swipe right on Clora? 💖",
    type: InputType.singleSelect,
    options: [
      "Cycle tracking",
      "Pain relief",
      "Health glow-up",
      "Pregnancy planning",
      "All of it ✨",
    ],
  ),
  FuQuestion(
    key: "cycle_length",
    question:
    "Your cycle is more like a Netflix series or a mini-episode? (21–35 days)",
    type: InputType.number,
  ),
  FuQuestion(
    key: "pain_level",
    question:
    "Be honest… are your cramps a mild protest or a full-scale rebellion?",
    type: InputType.slider,
  ),
  FuQuestion(
    key: "symptoms",
    question:
    "Which of these side-characters show up with your period?",
    type: InputType.multiSelect,
    options: [
      "Cramps",
      "Mood swings",
      "Bloating",
      "Fatigue",
      "Headache",
      "Nausea",
      "Acne",
    ],
  ),
  // mobile
  FuQuestion(
    key: "mobile",
    question:
    "Where should I send your insights and reminders?",
    type: InputType.number,
  ),

  /// ✅ EMAIL (LAST STEPS)
  FuQuestion(
    key: "email",
    question:
    "Where should I mail your insights and reminders? 📧",
    type: InputType.text,
    keyboardType: TextInputType.emailAddress,
  ),

  FuQuestion(
    key: "password",
    question:
    "Set a password so I can keep your data safe 🔐",
    type: InputType.text,
  ),
];

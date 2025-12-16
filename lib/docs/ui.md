# TAPCET Mobile UI Plan (Flutter)

This document describes the planned Flutter mobile UI for the TAPCET quiz app, based on the backend capabilities in `tapcet-api`.

## Goals

- Provide a clear screen map and navigation flow for a quiz app.
- Map each screen/action to the backend endpoints it needs.
- Keep the first implementation realistic: minimal, reliable, and aligned to the backend rules.

## Assumptions

- Backend provides JWT authentication and role claims (User/Admin).
- Quiz attempts are started server-side and submitted once with all answers.
- Quizzes can be created/managed by their owner (or Admin).

---

## Information Architecture

### App Sections

- **Auth**: register/login
- **Discover**: active quizzes users can take
- **My Attempts**: attempt history + results
- **Creator**: create/manage quizzes (for users who create quizzes)
- **Leaderboard**: top results per quiz
- **Admin** (optional phase): manage everything

### Navigation (recommended)

- After login: `BottomNavigationBar` with 3–4 tabs
  - Discover
  - My Attempts
  - My Quizzes (creator)
  - Profile (optional)

If you want fewer tabs, start with:
- Discover
- My Attempts
- Profile

---

## Screen-by-Screen Plan (with API mapping)

### 1) Authentication

#### 1.1 Login

**Purpose**: Authenticate and obtain JWT.

- UI: Email, Password, Login button, link to Register
- API:
  - `POST /api/auth/login`
- Success:
  - Store JWT securely
  - Navigate to main app shell

#### 1.2 Register

**Purpose**: Create a new account.

- UI: Username, Email, Password, Confirm Password
- Backend constraints to reflect in UI validation:
  - Username length: 3–20
  - Password: 6+ chars with uppercase, lowercase, digit
- API:
  - `POST /api/auth/check-email` (optional pre-check)
  - `POST /api/auth/register`

---

### 2) Discover / Dashboard

#### 2.1 Discover (Active Quizzes)

**Purpose**: Browse quizzes available for taking.

- UI:
  - List/grid of quiz cards (title, description, question count)
  - Pull-to-refresh
  - Tap quiz → Quiz Details
- API:
  - `GET /api/quiz/active`

#### 2.2 Quiz Details

**Purpose**: Show quiz metadata and allow user to start attempt.

- UI:
  - Title, description, question count
  - CTA: Start Quiz
- API:
  - `GET /api/quiz/{id}`
  - `POST /api/attempt/start`

Notes:
- If backend rejects attempt start (inactive quiz / no questions), show friendly error.

---

### 3) Quiz Taking Flow

#### 3.1 Quiz Taking (Questions)

**Purpose**: Let user answer questions and submit.

- UI:
  - Progress indicator (e.g., 3/10)
  - Question text
  - Optional image (if `ImageUrl` exists)
  - Choices as radio list (single select)
  - Previous/Next navigation
  - Submit button at end
- Backend rules to reflect:
  - Must answer all questions before submit
  - Prevent double submission (handle API error)
- API:
  - Questions/choices come from `POST /api/attempt/start` response (attempt payload)
  - `POST /api/attempt/submit`

Submission payload (conceptual):
- Attempt identifier + map/list of answers (questionId → choiceId)

---

### 4) Results & Review

#### 4.1 Attempt Result Summary

**Purpose**: Show score and next actions.

- UI:
  - Score (0–100)
  - Correct vs incorrect count
  - Completed time
  - Buttons: View Detailed Review, View Leaderboard, Back to Discover
- API:
  - `GET /api/attempt/{id}` (basic)
  - or `GET /api/attempt/{id}/result` (richer)

#### 4.2 Detailed Review

**Purpose**: Question-by-question breakdown.

- UI:
  - Each question with:
    - user selected choice
    - correct choice
    - explanation (if present)
- API:
  - `GET /api/attempt/{id}/result`

---

### 5) My Attempts

#### 5.1 Attempt History

**Purpose**: Let users see their past attempts.

- UI:
  - List of attempts (quiz title, date, score)
  - Tap attempt → Result Summary
- API:
  - `GET /api/attempt/user`

#### 5.2 Quiz Attempts (per Quiz)

**Purpose**: Show attempts for a specific quiz (optional screen).

- API:
  - `GET /api/attempt/quiz/{quizId}`

---

### 6) Leaderboard

#### 6.1 Quiz Leaderboard

**Purpose**: Show top performers for a quiz.

- UI:
  - Rank, username, score, completion time
  - Highlight current user if present
- API:
  - `GET /api/attempt/quiz/{quizId}/leaderboard?topCount={n}`

---

## Creator Features (Quiz Management)

These screens assume the logged-in user can create quizzes (and owns the ones they created). If you want to restrict creation to Admin only, gate these screens behind the role.

### 7) My Quizzes

**Purpose**: Manage quizzes created by current user.

- UI:
  - List of user-created quizzes
  - Actions: Edit, Delete, Toggle Active
  - CTA: Create Quiz
- API:
  - `GET /api/quiz` (client filters to own quizzes if API returns all; ideally backend provides “mine” endpoint)
  - `PATCH /api/quiz/{id}/toggle`
  - `DELETE /api/quiz/{id}`

### 8) Create Quiz

**Purpose**: Create quiz container.

- UI: Title, Description, Save
- API:
  - `POST /api/quiz`

### 9) Add Questions

**Purpose**: Add questions + choices to a quiz.

- UI:
  - Question text
  - Optional explanation
  - Optional image URL
  - 2–6 choices
  - Exactly 1 correct choice
- API:
  - `POST /api/quiz/{id}/questions`

### 10) Edit Quiz

**Purpose**: Update quiz metadata.

- API:
  - `PUT /api/quiz/{id}`

---

## Role-Based UI Rules

- **User**:
  - Can take quizzes
  - Can view own attempts
  - Can manage own quizzes (if creation enabled)

- **Admin**:
  - Can manage all quizzes
  - Can delete/update any quiz

UI gating:
- Read role(s) from JWT claims after login.
- Hide admin screens unless Admin role exists.

---

## Error Handling Requirements

Map backend errors into clear UI states:

- **400 Bad Request**: show validation message (e.g., missing answers)
- **401 Unauthorized**: token expired → force login
- **403 Forbidden**: show “not allowed” (quiz not owned)
- **404 Not Found**: show “quiz/attempt not found”
- **500**: show generic error + retry

---

## Implementation Phases (Recommended)

### Phase 1 (Core user flow)

- Login/Register
- Discover active quizzes
- Quiz details → start attempt
- Take quiz → submit
- Results summary + detailed review
- My attempts list
- Leaderboard

### Phase 2 (Creator flow)

- My Quizzes
- Create quiz
- Add questions
- Edit/toggle/delete

### Phase 3 (Admin)

- Admin dashboard + full quiz moderation

---

## Minimal Data Models (Frontend)

Define lightweight DTOs matching backend payloads:

- `UserSession`: token, userId, username, roles, expiresAt
- `Quiz`: id, title, description, isActive, createdById, questionCount
- `Question`: id, text, explanation?, imageUrl?, choices[]
- `Choice`: id, text
- `Attempt`: id, quizId, startedAt, completedAt?, score?
- `AttemptResult`: attemptId, score, items[] (question + correct + selected + explanation)

---

## Notes / Open Questions

1. Does `GET /api/quiz` return **all** quizzes or only current user’s quizzes? If it returns all, we should filter on the client using `createdById` (requires backend to include that field in responses).
2. What is the exact request body expected by `POST /api/attempt/submit`? (attemptId + answers structure)
3. What does `POST /api/attempt/start` return exactly? (attemptId + questions/choices)

Once we confirm (2) and (3), we can implement the client services and providers precisely.

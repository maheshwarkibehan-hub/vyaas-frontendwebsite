# INBOX NOTIFICATION TESTING GUIDE

## Problem:
Payment approval/rejection messages are not appearing in the inbox.

## Debugging Steps:

### 1. Check Browser Console
Open browser console (F12) and look for:
- ✅ "Payment approval notification created: [...]" - Means notification was inserted
- ❌ "Error creating approval notification: [...]" - Means insert failed
- ✅ "Notification real-time event: INSERT [...]" - Means real-time is working

### 2. Check Supabase Database
Go to Supabase Dashboard → Table Editor → `user_notifications`
- Verify that new rows are being created when you approve/reject payments
- Check the `user_id` matches the user who made the payment request
- Check `is_read` is `false`

### 3. Check Real-time Connection
In browser console, look for:
- "Notification real-time event: ..." - Should appear when notification is inserted
- If you don't see this, real-time subscription is not working

### 4. Manual Test
Run this in Supabase SQL Editor to manually insert a test notification:

```sql
-- Replace 'YOUR_USER_ID' with actual Firebase UID
INSERT INTO public.user_notifications (user_id, title, message, type, is_read)
VALUES ('YOUR_USER_ID', '🧪 Test Notification', 'This is a test message', 'info', false);
```

Then:
1. Open the inbox
2. Check if the test notification appears
3. Check browser console for "Notification real-time event: INSERT"

### 5. Force Refresh Inbox
The inbox now auto-refreshes when you open it, so:
1. Close inbox
2. Approve a payment
3. Open inbox again
4. Message should appear

## Common Issues:

### Issue 1: Notification inserted but not appearing
**Cause**: Real-time subscription not working
**Fix**: 
- Verify `FINAL_DB_SETUP_FIREBASE.sql` was run
- Check that `user_notifications` is in realtime publication
- Restart the app (refresh browser)

### Issue 2: Notification not inserted at all
**Cause**: RLS policy blocking insert
**Fix**:
- Run `FINAL_DB_SETUP_FIREBASE.sql` again
- Check console for "Error creating approval notification"

### Issue 3: Wrong user_id
**Cause**: Payment request has wrong user_id
**Fix**:
- Check payment_requests table in Supabase
- Verify user_id is the Firebase UID (not email)

## Expected Flow:
1. Admin approves payment → Console logs "Payment approval notification created"
2. Notification inserted into DB → Real-time triggers
3. Inbox subscription receives event → Console logs "Notification real-time event: INSERT"
4. Inbox UI updates → New message appears
5. Badge count updates → Red circle shows unread count

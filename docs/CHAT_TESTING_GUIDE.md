# Chat Functionality Testing Guide

## Overview
This guide provides a comprehensive testing plan for the chat functionality in the Barter Queen app. The chat feature allows users to message each other from both the item detail page and user profile page.

## Features to Test

### 1. Chat from Item Detail Page
**Location:** Item Detail Page → "Message Owner" button

**Test Cases:**
1. **Start New Conversation from Item**
   - Navigate to any item detail page
   - Tap "Message Owner" button
   - Verify a loading dialog appears with "Starting conversation..."
   - Verify navigation to chat detail page
   - Verify item listing ID is associated with conversation

2. **Return to Existing Conversation from Item**
   - Start a conversation from an item
   - Navigate back
   - Navigate to the same item again
   - Tap "Message Owner" button
   - Verify the existing conversation is loaded (not a new one)

3. **Own Item - No Message Button**
   - Navigate to your own item detail page
   - Verify "Message Owner" button is NOT visible

### 2. Chat from User Profile Page
**Location:** User Profile Page → "Send Message" button

**Test Cases:**
1. **Start New Conversation from Profile**
   - Navigate to another user's profile
   - Tap "Send Message" button
   - Verify a loading dialog appears with "Starting conversation..."
   - Verify navigation to chat detail page
   - Verify no specific listing ID (generic conversation)

2. **Return to Existing Conversation from Profile**
   - Start a conversation from a user profile
   - Navigate back
   - Navigate to the same user's profile again
   - Tap "Send Message" button
   - Verify the existing conversation is loaded

3. **Own Profile - No Message Button**
   - Navigate to your own profile
   - Verify "Send Message" button is NOT visible

### 3. Chat Detail Page
**Location:** Chat Detail Page (accessed from item or profile)

**Test Cases:**
1. **Send Text Message**
   - Type a message in the text field
   - Tap send button (or press Enter)
   - Verify message appears immediately in the chat
   - Verify message is right-aligned with gradient background
   - Verify message shows timestamp
   - Verify text field clears after sending

2. **Receive Messages (Real-time)**
   - Have another user send a message
   - Verify message appears automatically (no refresh needed)
   - Verify message is left-aligned with white background
   - Verify sender avatar is shown

3. **Empty Chat State**
   - Start a new conversation
   - Verify empty state shows:
     - Chat bubble icon
     - "No messages yet" text
     - "Say hello!" prompt

4. **Message History**
   - Send multiple messages
   - Scroll up to see older messages
   - Verify all messages are displayed correctly
   - Verify proper ordering (newest at bottom)

5. **Auto-scroll to Bottom**
   - Have long conversation with many messages
   - Send a new message
   - Verify view auto-scrolls to show the new message

6. **Mark as Read**
   - Open a conversation with unread messages
   - Verify unread count updates in conversation list
   - Verify messages are marked as read

### 4. Conversation List
**Location:** Main Navigation → Chats Tab

**Test Cases:**
1. **View All Conversations**
   - Navigate to Chats tab
   - Verify all conversations are listed
   - Verify ordered by most recent activity

2. **Conversation Preview**
   - View conversation list
   - Verify each item shows:
     - Other user's avatar
     - Last message preview
     - Timestamp
     - Unread badge (if applicable)

3. **Empty Conversation List**
   - Fresh account with no conversations
   - Navigate to Chats tab
   - Verify empty state shows appropriate message

4. **Real-time Updates**
   - Have another user send you a message
   - Verify conversation list updates automatically
   - Verify conversation moves to top of list
   - Verify unread badge appears

### 5. Error Handling

**Test Cases:**
1. **Network Error**
   - Disable internet connection
   - Try to send a message
   - Verify error message is shown
   - Enable internet
   - Verify message sends automatically or shows retry option

2. **Invalid User ID**
   - Attempt to message non-existent user
   - Verify appropriate error message

3. **Self-Messaging Prevention**
   - Backend validation prevents messaging yourself
   - Verify UI never shows option to message yourself

4. **Firebase Rules Compliance**
   - Verify only authenticated users can access conversations
   - Verify users can only access their own conversations
   - Verify proper read/write permissions

## Backend Validation

### Firebase Security Rules
Check that the following rules are properly configured:

```javascript
// Conversations Collection
match /conversations/{conversationId} {
  allow read: if request.auth != null && 
    request.auth.uid in resource.data.participants;
  allow create: if request.auth != null && 
    request.auth.uid in request.resource.data.participants;
  allow update: if request.auth != null && 
    request.auth.uid in resource.data.participants;
}

// Messages Collection
match /messages/{messageId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && 
    request.auth.uid == request.resource.data.senderId;
}
```

### Data Structure Validation

**Conversation Document:**
```json
{
  "participants": ["userId1", "userId2"],
  "listingId": "optional-item-id",
  "lastMessage": "Last message text",
  "lastMessageSenderId": "userId",
  "lastMessageTime": Timestamp,
  "unreadCount": {
    "userId1": 0,
    "userId2": 1
  },
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

**Message Document:**
```json
{
  "conversationId": "conv-id",
  "senderId": "user-id",
  "senderName": "User Name",
  "text": "Message text",
  "type": "text",
  "createdAt": Timestamp,
  "isRead": false,
  "imageUrl": null
}
```

## Testing Flow

### Recommended Testing Order:
1. **Setup**: Create test accounts (minimum 2 users)
2. **Basic Flow**: Test starting conversation from item detail page
3. **Profile Flow**: Test starting conversation from user profile page
4. **Message Exchange**: Send messages back and forth between users
5. **Real-time**: Verify real-time updates work correctly
6. **Edge Cases**: Test error scenarios and validation
7. **Performance**: Test with longer message history

### Multi-Device Testing:
- Test on 2+ devices simultaneously
- Verify real-time synchronization
- Check performance with concurrent users

## Known Issues & Limitations

1. **Display Name in App Bar**: 
   - Currently shows truncated user ID
   - TODO: Fetch and display actual user display name

2. **User Avatar**: 
   - Currently shows generic person icon
   - TODO: Fetch and display user's actual profile photo

3. **Message Options**:
   - No message deletion yet
   - No message editing yet
   - No message reactions yet

4. **Media Support**:
   - Currently text-only messages
   - Image/file sharing not implemented yet

## Success Criteria

✅ Users can start conversations from item detail pages
✅ Users can start conversations from user profiles  
✅ Messages send and receive in real-time
✅ UI prevents messaging yourself
✅ Backend validation prevents invalid operations
✅ Error messages are clear and actionable
✅ Proper loading states shown during operations
✅ Chat UI is responsive and intuitive
✅ Message history persists correctly
✅ Unread counts update properly

## Next Steps

After completing testing:
1. Fix any bugs discovered during testing
2. Enhance UI with user photos and display names
3. Add message options (delete, edit, react)
4. Implement media sharing (images, files)
5. Add typing indicators
6. Add online/offline status
7. Implement push notifications for new messages

---

**Last Updated:** [Current Date]
**Version:** 1.0
**Status:** Ready for Testing

"""
Email service for syncing UCL Outlook emails via IMAP.
"""
import imaplib
import email
from email.header import decode_header
from typing import List, Dict, Any, Optional
from datetime import datetime
import logging
from bs4 import BeautifulSoup
import re

from config import settings

logger = logging.getLogger(__name__)


class EmailService:
    """Service for syncing emails from UCL Outlook via IMAP."""

    def __init__(self, user_email: str, user_password: str):
        self.server = settings.EMAIL_IMAP_SERVER
        self.port = settings.EMAIL_IMAP_PORT
        self.user_email = user_email
        self.user_password = user_password
        self.imap = None

    def connect(self):
        """Connect to IMAP server."""
        try:
            self.imap = imaplib.IMAP4_SSL(self.server, self.port)
            self.imap.login(self.user_email, self.user_password)
            logger.info(f"Successfully connected to IMAP server for {self.user_email}")
        except Exception as e:
            logger.error(f"Error connecting to IMAP server: {e}")
            raise

    def disconnect(self):
        """Disconnect from IMAP server."""
        if self.imap:
            try:
                self.imap.logout()
            except Exception as e:
                logger.error(f"Error disconnecting from IMAP: {e}")

    def _decode_header(self, header_value: str) -> str:
        """Decode email header."""
        if not header_value:
            return ""

        decoded_parts = decode_header(header_value)
        result = []

        for part, encoding in decoded_parts:
            if isinstance(part, bytes):
                try:
                    result.append(part.decode(encoding or 'utf-8', errors='ignore'))
                except:
                    result.append(part.decode('utf-8', errors='ignore'))
            else:
                result.append(str(part))

        return ' '.join(result)

    def _extract_text_from_html(self, html: str) -> str:
        """Extract plain text from HTML."""
        soup = BeautifulSoup(html, 'html.parser')
        # Remove script and style elements
        for script in soup(["script", "style"]):
            script.decompose()
        text = soup.get_text()
        # Clean up whitespace
        lines = (line.strip() for line in text.splitlines())
        chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
        text = '\n'.join(chunk for chunk in chunks if chunk)
        return text

    def _categorize_email(self, subject: str, sender: str, body: str) -> str:
        """Categorize email based on content."""
        subject_lower = subject.lower()
        body_lower = body.lower()
        sender_lower = sender.lower()

        # Urgent keywords
        urgent_keywords = ['urgent', 'deadline', 'overdue', 'reminder', 'action required', 'important']
        if any(keyword in subject_lower or keyword in body_lower for keyword in urgent_keywords):
            return "urgent"

        # Academic keywords
        academic_keywords = ['lecture', 'assignment', 'exam', 'coursework', 'module', 'tutorial', 'seminar']
        if any(keyword in subject_lower or keyword in body_lower for keyword in academic_keywords):
            return "academic"

        # Events keywords
        event_keywords = ['event', 'workshop', 'seminar', 'conference', 'career fair', 'register']
        if any(keyword in subject_lower or keyword in body_lower for keyword in event_keywords):
            return "events"

        # UCL administrative
        if 'ucl.ac.uk' in sender_lower and any(word in sender_lower for word in ['registry', 'library', 'admin']):
            return "administrative"

        return "other"

    async def fetch_recent_emails(self, folder: str = "INBOX", limit: int = 50) -> List[Dict[str, Any]]:
        """
        Fetch recent emails from IMAP server.

        Args:
            folder: IMAP folder to fetch from
            limit: Maximum number of emails to fetch

        Returns:
            List of email dictionaries
        """
        emails = []

        try:
            # Connect if not connected
            if not self.imap:
                self.connect()

            # Select mailbox
            self.imap.select(folder)

            # Search for all emails
            status, messages = self.imap.search(None, 'ALL')
            if status != 'OK':
                logger.error("Failed to search emails")
                return []

            # Get message IDs
            message_ids = messages[0].split()

            # Fetch latest emails (reverse order)
            for msg_id in reversed(message_ids[-limit:]):
                try:
                    # Fetch email
                    status, msg_data = self.imap.fetch(msg_id, '(RFC822)')
                    if status != 'OK':
                        continue

                    # Parse email
                    raw_email = msg_data[0][1]
                    email_message = email.message_from_bytes(raw_email)

                    # Extract headers
                    subject = self._decode_header(email_message.get('Subject', ''))
                    sender = self._decode_header(email_message.get('From', ''))
                    date_str = email_message.get('Date', '')
                    message_id = email_message.get('Message-ID', '')

                    # Parse date
                    try:
                        date_tuple = email.utils.parsedate_to_datetime(date_str)
                        received_at = date_tuple
                    except:
                        received_at = datetime.now()

                    # Extract body
                    body_text = ""
                    body_html = ""

                    if email_message.is_multipart():
                        for part in email_message.walk():
                            content_type = part.get_content_type()
                            if content_type == "text/plain":
                                try:
                                    body_text = part.get_payload(decode=True).decode('utf-8', errors='ignore')
                                except:
                                    pass
                            elif content_type == "text/html":
                                try:
                                    body_html = part.get_payload(decode=True).decode('utf-8', errors='ignore')
                                except:
                                    pass
                    else:
                        try:
                            body_text = email_message.get_payload(decode=True).decode('utf-8', errors='ignore')
                        except:
                            pass

                    # If only HTML, extract text
                    if not body_text and body_html:
                        body_text = self._extract_text_from_html(body_html)

                    # Create excerpt
                    excerpt = body_text[:200] if body_text else ""

                    # Categorize email
                    category = self._categorize_email(subject, sender, body_text)

                    # Extract sender name and email
                    sender_match = re.match(r'(.*?)\s*<(.+?)>', sender)
                    sender_name = sender_match.group(1).strip() if sender_match else sender
                    sender_email = sender_match.group(2) if sender_match else sender

                    email_dict = {
                        "message_id": message_id,
                        "subject": subject,
                        "sender": sender_email,
                        "sender_name": sender_name,
                        "body_text": body_text,
                        "body_html": body_html,
                        "excerpt": excerpt,
                        "category": category,
                        "received_at": received_at,
                        "is_read": False  # Can be determined from IMAP flags if needed
                    }

                    emails.append(email_dict)

                except Exception as e:
                    logger.error(f"Error parsing email {msg_id}: {e}")
                    continue

        except Exception as e:
            logger.error(f"Error fetching emails: {e}")
        finally:
            # Don't disconnect here, let the caller handle it
            pass

        return emails

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.disconnect()

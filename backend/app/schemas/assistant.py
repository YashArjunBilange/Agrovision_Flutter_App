from typing import List, Optional
from pydantic import BaseModel, Field


class ChatMessageRequest(BaseModel):
    message: str = Field(..., min_length=1)
    farm_id: Optional[int] = None
    language: str = Field(default="mr", pattern="^(en|mr)$")


class ChatMessageResponse(BaseModel):
    reply: str
    language: str
    suggestions: List[str] = []
    context_used: bool = False


class QuickPromptResponse(BaseModel):
    title_en: str
    title_mr: str
    prompt_en: str
    prompt_mr: str

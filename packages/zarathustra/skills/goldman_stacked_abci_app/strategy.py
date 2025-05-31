"""This package contains the goldman_stacked models."""

from enum import Enum
from typing import Any
from pathlib import Path
from collections import deque

from aea.skills.base import Model

from packages.eightballer.protocols.chatroom.message import ChatroomMessage


MESSAGE_HISTORY_SIZE = 10
MAX_QUEUE_LENGTH = 1_000


class LLMActions(Enum):
    """LLMActions."""

    WORKFLOW = "workflow"
    REPLY = "reply"


class GoldmanStackedStrategy(Model):
    """This class models the AdvancedDataRequest skill."""

    user_persona: str
    data_dir: str
    new_users: deque[dict] = deque(maxlen=MAX_QUEUE_LENGTH)
    pending_telegram_messages: deque[ChatroomMessage] = deque(maxlen=MAX_QUEUE_LENGTH)
    chat_history: deque[str] = deque(maxlen=MESSAGE_HISTORY_SIZE)
    llm_responses: deque[tuple[LLMActions, str]] = deque(maxlen=MAX_QUEUE_LENGTH)
    pending_workflows: deque[str] = deque(maxlen=MAX_QUEUE_LENGTH)
    telegram_responses: deque[str] = deque(maxlen=MAX_QUEUE_LENGTH)
    data_dir: Path
    output_dir: Path
    from_config: bool = False

    workflows = {}  # TODO

    def __init__(self, **kwargs: Any) -> None:
        """Initialize dialogues."""
        self.data_dir = Path(kwargs.pop("data_dir", "data"))
        self.output_dir = Path(kwargs.pop("output_dir", "output"))
        self.user_persona = ""
        Model.__init__(self, **kwargs)


class AgentPersona(Model):
    """AgentPersona."""

    def __init__(self, **kwargs: Any) -> None:
        """Initialize agent persona."""
        # for key, anno in self.__annotations__.items():
        #     if (value := kwargs.get(key)) is None:
        #         msg = f"Missing required parameter: {key} of type {anno}"
        #         raise ValueError(msg)
        #     setattr(self, key, value)
        Model.__init__(self, **kwargs)

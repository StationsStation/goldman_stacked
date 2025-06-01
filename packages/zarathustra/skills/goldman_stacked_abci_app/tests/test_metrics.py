"""Test the metrics skill."""

from typing import cast
from pathlib import Path

from aea.test_tools.test_skill import BaseSkillTestCase
from aea.protocols.dialogue.base import DialogueMessage

from packages.eightballer.protocols.http.message import HttpMessage
from packages.zarathustra.skills.goldman_stacked_abci_app import PUBLIC_ID
from packages.zarathustra.skills.goldman_stacked_abci_app.handlers import HttpHandler
from packages.zarathustra.skills.goldman_stacked_abci_app.dialogues import HttpDialogues


ROOT_DIR = Path(__file__).parent.parent.parent.parent.parent.parent


class TestHttpHandler(BaseSkillTestCase):
    """Test HttpHandler of http_echo."""

    path_to_skill = Path(ROOT_DIR, "packages", PUBLIC_ID.author, "skills", PUBLIC_ID.name)

    @classmethod
    def setup(cls):  # pylint: disable=W0221
        """Setup the test class."""
        super().setup_class()
        cls.http_handler = cast(HttpHandler, cls._skill.skill_context.handlers.metrics_handler)
        cls.logger = cls._skill.skill_context.logger

        cls.http_dialogues = cast(HttpDialogues, cls._skill.skill_context.http_dialogues)

        cls.get_method = "get"
        cls.post_method = "post"
        cls.url = "localhost:8000/metrics"
        cls.version = "some_version"
        cls.headers = "some_headers"
        cls.body = b"some_body"
        cls.sender = "fetchai/some_skill:0.1.0"
        cls.skill_id = str(cls._skill.skill_context.skill_id)

        cls.status_code = 100
        cls.status_text = "some_status_text"

        cls.content = b"some_content"
        cls.list_of_messages = (
            DialogueMessage(
                HttpMessage.Performative.REQUEST,
                {
                    "method": cls.get_method,
                    "url": cls.url,
                    "version": cls.version,
                    "headers": cls.headers,
                    "body": cls.body,
                },
            ),
        )

    def test_setup(self):
        """Test the setup method of the http_echo handler."""
        assert self.http_handler.setup() is None
        self.assert_quantity_in_outbox(0)

    def test_teardown(self):
        """Test the teardown method of the http_echo handler."""
        assert self.http_handler.teardown() is None
        self.assert_quantity_in_outbox(0)

    @classmethod
    def teardown(cls, *args, **kwargs):  # noqa
        """Teardown the test class."""
        db_fn = Path("test.db")
        if db_fn.exists():
            db_fn.unlink()
